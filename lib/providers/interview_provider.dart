import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/interview_models.dart';
import '../services/audio_interview_service.dart';
import 'locale_provider.dart';

enum InterviewConnectionStatus {
  idle,
  connecting,
  connected,
  recording,
  processing,
  completed,
  error,
}

class InterviewState {
  const InterviewState({
    this.status = InterviewConnectionStatus.idle,
    this.history = const [],
    this.lastFeedback,
    this.errorMessage,
  });

  final InterviewConnectionStatus status;
  final List<ConversationTurn> history;
  final Map<String, dynamic>? lastFeedback;
  final String? errorMessage;

  InterviewState copyWith({
    InterviewConnectionStatus? status,
    List<ConversationTurn>? history,
    Map<String, dynamic>? lastFeedback,
    String? errorMessage,
  }) {
    return InterviewState(
      status: status ?? this.status,
      history: history ?? this.history,
      lastFeedback: lastFeedback ?? this.lastFeedback,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Orchestrates one mock-interview session: connects the WebSocket,
/// drives push-to-talk recording, appends each round-trip to the visible
/// transcript, and plays back the AI's spoken reply automatically.
///
/// One controller instance == one interview session. The screen creates
/// it fresh (via the provider) when the interview starts and lets Riverpod
/// dispose it — and the underlying socket/recorder/player — when the
/// screen is popped.
class InterviewController extends Notifier<InterviewState> {
  late final AudioInterviewService _service;
  StreamSubscription<InterviewTurnResponse>? _responseSub;
  StreamSubscription<Object>? _errorSub;

  @override
  InterviewState build() {
    _service = AudioInterviewService();
    ref.onDispose(() {
      _responseSub?.cancel();
      _errorSub?.cancel();
      _service.dispose();
    });
    return const InterviewState();
  }

  Future<void> startInterview(String interviewId) async {
    // The controller isn't autoDispose (the WS/audio service needs to
    // survive incidental rebuilds), so a fresh screen mount must reset any
    // leftover transcript/feedback/error from a previous session itself.
    state = const InterviewState(status: InterviewConnectionStatus.connecting);
    try {
      final token =
          Supabase.instance.client.auth.currentSession?.accessToken ?? '';
      await _service.connect(interviewId: interviewId, accessToken: token);

      _responseSub = _service.responses.listen(_onTurnResult);
      _errorSub = _service.errors.listen((error) {
        state = state.copyWith(
          status: InterviewConnectionStatus.error,
          errorMessage: _friendlyMessage(),
        );
      });

      state = state.copyWith(status: InterviewConnectionStatus.connected);
    } catch (error) {
      state = state.copyWith(
        status: InterviewConnectionStatus.error,
        errorMessage: _friendlyMessage(),
      );
    }
  }

  /// The only user-facing error copy this screen has today — kept as a
  /// single localized fallback (rather than surfacing `error.toString()`
  /// directly) so a WebSocket/transport exception, a denied mic permission,
  /// or a failed recording never leaks raw, unlocalized English text.
  String _friendlyMessage() {
    return lookupAppLocalizations(ref.read(localeProvider))
        .mockInterviewConnectionError;
  }

  void _onTurnResult(InterviewTurnResponse turn) {
    final updatedHistory = [
      ...state.history,
      ConversationTurn(speaker: 'user', text: turn.userTranscript),
      ConversationTurn(speaker: 'ai', text: turn.aiQuestionText),
    ];

    state = state.copyWith(
      status: turn.isInterviewComplete
          ? InterviewConnectionStatus.completed
          : InterviewConnectionStatus.connected,
      history: updatedHistory,
      lastFeedback: turn.feedback,
    );

    // Fire-and-forget: playback shouldn't block state updates or the UI.
    unawaited(_service.playAiAudio(turn.aiAudioBase64));
  }

  Future<void> startAnswer() async {
    if (state.status != InterviewConnectionStatus.connected) return;
    try {
      state = state.copyWith(status: InterviewConnectionStatus.recording);
      await _service.startRecording();
    } catch (error) {
      state = state.copyWith(
        status: InterviewConnectionStatus.error,
        errorMessage: _friendlyMessage(),
      );
    }
  }

  Future<void> submitAnswer() async {
    if (state.status != InterviewConnectionStatus.recording) return;
    try {
      state = state.copyWith(status: InterviewConnectionStatus.processing);
      await _service.stopRecordingAndSend(state.history);
      // status transitions to `connected` or `completed` once the
      // server's turn_result arrives via _onTurnResult.
    } catch (error) {
      state = state.copyWith(
        status: InterviewConnectionStatus.error,
        errorMessage: _friendlyMessage(),
      );
    }
  }

  Future<void> endInterview() async {
    await _service.disconnect();
    state = state.copyWith(status: InterviewConnectionStatus.idle);
  }
}

final interviewControllerProvider =
    NotifierProvider<InterviewController, InterviewState>(
        InterviewController.new);

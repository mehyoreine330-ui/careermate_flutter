import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/career_coach_models.dart';
import 'locale_provider.dart';
import 'resume_provider.dart';

class CoachChatState {
  const CoachChatState({
    this.messages = const [],
    this.isLoadingHistory = false,
    this.isSending = false,
    this.errorMessage,
  });

  final List<CoachMessage> messages;
  final bool isLoadingHistory;
  final bool isSending;
  final String? errorMessage;

  CoachChatState copyWith({
    List<CoachMessage>? messages,
    bool? isLoadingHistory,
    bool? isSending,
    String? errorMessage,
  }) {
    return CoachChatState(
      messages: messages ?? this.messages,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the AI Career Coach chat: loads the persisted conversation once,
/// then sends new messages and appends the coach's reply. Errors surface as
/// a friendly inline message rather than a crash — the failed user message
/// stays in the transcript so the user can just try again.
class CoachChatController extends Notifier<CoachChatState> {
  @override
  CoachChatState build() => const CoachChatState();

  bool _historyLoaded = false;

  Future<void> loadHistory() async {
    if (_historyLoaded) return;
    _historyLoaded = true;

    state = state.copyWith(isLoadingHistory: true);
    try {
      final history = await ref.read(apiServiceProvider).getCoachHistory();
      state = state.copyWith(messages: history, isLoadingHistory: false);
    } catch (error) {
      _historyLoaded = false; // allow retry on next screen visit
      state = state.copyWith(
        isLoadingHistory: false,
        errorMessage: _friendlyMessage(error),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final userMessage = CoachMessage(role: 'user', content: trimmed, createdAt: DateTime.now());
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      errorMessage: null,
    );

    try {
      final language = ref.read(localeProvider).languageCode;
      final reply = await ref.read(apiServiceProvider).sendCoachMessage(trimmed, language: language);
      final aiMessage = CoachMessage(role: 'assistant', content: reply, createdAt: DateTime.now());
      state = state.copyWith(messages: [...state.messages, aiMessage], isSending: false);
    } catch (error) {
      state = state.copyWith(isSending: false, errorMessage: _friendlyMessage(error));
    }
  }

  String _friendlyMessage(Object error) {
    final l10n = lookupAppLocalizations(ref.read(localeProvider));
    if (error is ApiException) {
      return error.statusCode == 502 ? l10n.careerCoachErrorRespond : error.message;
    }
    return l10n.commonSomethingWentWrong;
  }
}

final coachChatProvider = NotifierProvider<CoachChatController, CoachChatState>(CoachChatController.new);

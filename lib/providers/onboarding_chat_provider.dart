import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_exception.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/onboarding_chat_models.dart';
import 'auth_provider.dart';
import 'locale_provider.dart';
import 'profile_provider.dart';
import 'resume_provider.dart';

class OnboardingChatState {
  const OnboardingChatState({
    this.messages = const [],
    this.currentFieldKey,
    this.isSending = false,
    this.isComplete = false,
    this.errorMessage,
  });

  final List<OnboardingChatMessage> messages;

  /// The profiles column the *next* answer the user sends should be saved
  /// under. Null before the chat has started, or once it's complete.
  final String? currentFieldKey;
  final bool isSending;
  final bool isComplete;
  final String? errorMessage;

  OnboardingChatState copyWith({
    List<OnboardingChatMessage>? messages,
    String? currentFieldKey,
    bool? isSending,
    bool? isComplete,
    String? errorMessage,
  }) {
    return OnboardingChatState(
      messages: messages ?? this.messages,
      currentFieldKey: currentFieldKey ?? this.currentFieldKey,
      isSending: isSending ?? this.isSending,
      isComplete: isComplete ?? this.isComplete,
      errorMessage: errorMessage,
    );
  }
}

/// Drives the AI Welcome onboarding chat: fetches each AI-phrased message
/// from `POST /api/v1/onboarding/respond`, and — same pattern as the rest of
/// the app's profile writes — saves each answer straight to Supabase's
/// `profiles` table directly from the client, RLS-protected, rather than
/// through FastAPI (which only generates the conversational text here).
class OnboardingChatController extends Notifier<OnboardingChatState> {
  @override
  OnboardingChatState build() => const OnboardingChatState();

  Future<void> start() async {
    if (state.messages.isNotEmpty) return; // already started
    state = state.copyWith(isSending: true);
    try {
      final api = ref.read(apiServiceProvider);
      final language = ref.read(localeProvider).languageCode;
      final response = await api.onboardingRespond(language: language);
      state = state.copyWith(
        messages: [OnboardingChatMessage(isFromAi: true, text: response.message)],
        currentFieldKey: response.nextFieldKey,
        isComplete: response.isComplete,
        isSending: false,
      );
    } catch (error) {
      state = state.copyWith(
        isSending: false,
        errorMessage: error is ApiException
            ? error.message
            : lookupAppLocalizations(ref.read(localeProvider)).commonSomethingWentWrong,
      );
    }
  }

  Future<void> submitAnswer(String answer) async {
    final fieldKey = state.currentFieldKey;
    if (fieldKey == null || state.isSending || answer.trim().isEmpty) return;

    final trimmed = answer.trim();
    state = state.copyWith(
      messages: [...state.messages, OnboardingChatMessage(isFromAi: false, text: trimmed)],
      isSending: true,
      errorMessage: null,
    );

    try {
      await _saveAnswer(fieldKey, trimmed);

      final api = ref.read(apiServiceProvider);
      final language = ref.read(localeProvider).languageCode;
      final response = await api.onboardingRespond(fieldKey: fieldKey, answer: trimmed, language: language);

      if (response.isComplete) {
        await _markOnboardingComplete();
        // Refresh the cached profile so the auth gate re-routes to the dashboard.
        ref.invalidate(userProfileProvider);
      }

      state = state.copyWith(
        messages: [...state.messages, OnboardingChatMessage(isFromAi: true, text: response.message)],
        currentFieldKey: response.nextFieldKey,
        isComplete: response.isComplete,
        isSending: false,
      );
    } catch (error) {
      state = state.copyWith(
        isSending: false,
        errorMessage: error is ApiException
            ? error.message
            : lookupAppLocalizations(ref.read(localeProvider)).commonSomethingWentWrong,
      );
    }
  }

  Future<void> _saveAnswer(String fieldKey, String answer) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(supabaseClientProvider).from('profiles').upsert({
      'id': user.id,
      'email': user.email ?? '',
      fieldKey: answer,
    });
  }

  Future<void> _markOnboardingComplete() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    await ref.read(supabaseClientProvider).from('profiles').upsert({
      'id': user.id,
      'email': user.email ?? '',
      'onboarding_completed': true,
    });
  }
}

final onboardingChatProvider =
    NotifierProvider<OnboardingChatController, OnboardingChatState>(OnboardingChatController.new);

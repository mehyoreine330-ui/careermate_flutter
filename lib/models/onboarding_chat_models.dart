/// Mirrors routers/onboarding.py's OnboardingRespondResponse.
class OnboardingChatResponse {
  const OnboardingChatResponse({
    required this.message,
    required this.nextFieldKey,
    required this.isComplete,
  });

  final String message;
  final String? nextFieldKey;
  final bool isComplete;

  factory OnboardingChatResponse.fromJson(Map<String, dynamic> json) => OnboardingChatResponse(
        message: json['message'] as String,
        nextFieldKey: json['next_field_key'] as String?,
        isComplete: json['is_complete'] as bool,
      );
}

/// One bubble in the onboarding chat transcript.
class OnboardingChatMessage {
  const OnboardingChatMessage({required this.isFromAi, required this.text});

  final bool isFromAi;
  final String text;
}

/// Mirrors models.schemas.ConversationTurn / InterviewTurnResponse on the
/// FastAPI side. These are exchanged over the mock-interview WebSocket.

class ConversationTurn {
  const ConversationTurn({required this.speaker, required this.text});

  final String speaker; // 'ai' | 'user'
  final String text;

  factory ConversationTurn.fromJson(Map<String, dynamic> json) => ConversationTurn(
        speaker: json['speaker'] as String,
        text: json['text'] as String,
      );

  Map<String, dynamic> toJson() => {'speaker': speaker, 'text': text};
}

class InterviewTurnResponse {
  const InterviewTurnResponse({
    required this.userTranscript,
    required this.aiQuestionText,
    required this.aiAudioBase64,
    this.feedback,
    required this.isInterviewComplete,
  });

  final String userTranscript;
  final String aiQuestionText;
  final String aiAudioBase64; // base64-encoded MP3 from OpenAI TTS
  final Map<String, dynamic>? feedback;
  final bool isInterviewComplete;

  factory InterviewTurnResponse.fromJson(Map<String, dynamic> json) => InterviewTurnResponse(
        userTranscript: json['user_transcript'] as String,
        aiQuestionText: json['ai_question_text'] as String,
        aiAudioBase64: json['ai_audio_base64'] as String,
        feedback: json['feedback'] as Map<String, dynamic>?,
        isInterviewComplete: json['is_interview_complete'] as bool? ?? false,
      );
}

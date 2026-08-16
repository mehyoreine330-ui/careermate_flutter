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

/// One answered (or skipped) question in the text mock-interview flow.
/// Mirrors models.schemas.InterviewAnswer on the FastAPI side.
class InterviewAnswer {
  const InterviewAnswer({required this.question, required this.answer});

  final String question;
  final String answer;

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
}

/// Result of POST /api/v1/interviews/text/evaluate — mirrors
/// models.schemas.InterviewEvaluationResult.
class InterviewEvaluationResult {
  const InterviewEvaluationResult({
    required this.overallScore,
    required this.strengths,
    required this.weaknesses,
    required this.communicationFeedback,
    required this.improvementSuggestions,
  });

  final int overallScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final String communicationFeedback;
  final List<String> improvementSuggestions;

  factory InterviewEvaluationResult.fromJson(Map<String, dynamic> json) => InterviewEvaluationResult(
        overallScore: json['overall_score'] as int,
        strengths: (json['strengths'] as List).cast<String>(),
        weaknesses: (json['weaknesses'] as List).cast<String>(),
        communicationFeedback: json['communication_feedback'] as String,
        improvementSuggestions: (json['improvement_suggestions'] as List).cast<String>(),
      );
}

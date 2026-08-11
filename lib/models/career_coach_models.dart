/// Mirrors careermate-backend's CoachMessage — one persisted turn of the AI
/// Career Coach conversation.
class CoachMessage {
  const CoachMessage({
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;

  bool get isFromAi => role == 'assistant';

  factory CoachMessage.fromJson(Map<String, dynamic> json) => CoachMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

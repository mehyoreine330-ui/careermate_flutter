class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String kind; // 'application_status' | 'new_applicant' | 'general'
  final bool read;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String? ?? '',
        kind: json['kind'] as String? ?? 'general',
        read: json['read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

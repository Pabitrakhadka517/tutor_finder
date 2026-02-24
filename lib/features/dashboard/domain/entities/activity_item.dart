/// A single activity item shown in the dashboard activity feed
class ActivityItem {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type, 'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}

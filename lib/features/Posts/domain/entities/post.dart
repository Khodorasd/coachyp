class Post {
  final String id;
  final String coachId;
  final String description;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;

  Post({
    required this.id,
    required this.coachId,
    required this.description,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
  });
}

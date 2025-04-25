// lib/features/posts/data/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required super.id,
    required super.coachId,
    required super.description,
    required super.imageUrl,
    required super.timestamp,
    required super.likes,
  });

  /// Creates a PostModel from a Firestore document.
  /// Falls back to `photoUrl` if `imageUrl` isn’t defined.
  factory PostModel.fromJson(Map<String, dynamic> json, String id) {
  // Prefer `imageUrl`, fall back to `photoUrl`
  final url = (json['imageUrl'] as String?)?.isNotEmpty == true
      ? json['imageUrl'] as String
      : (json['photoUrl'] as String?) ?? '';

  return PostModel(
    id: id,
    coachId: json['coachId'] as String? ?? '',
    description: json['description'] as String? ?? '',
    imageUrl: json['imageUrl'] as String? ?? '',
    timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    likes: List<String>.from(json['likes'] ?? []),
  );
}


  /// Converts this model back to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'coachId': coachId,
        'description': description,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.fromDate(timestamp),
        'likes': likes,
      };
}

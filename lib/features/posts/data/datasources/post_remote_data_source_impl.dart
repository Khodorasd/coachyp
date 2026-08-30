import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/features/posts/data/model/post_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'post_remote_data_source.dart';

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(PostModel post) async {
    try {
      final docRef = postsRef.doc(post.id);
      await docRef.set(post.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PostModel>> fetchPosts() async {
    try {
      final snapshot = await postsRef
          .where('isActive', isEqualTo: true) // ✅ ONLY fetch active posts
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PostModel>> fetchPostsByType(String type) async {
    try {
      final snapshot = await postsRef
          .where('type', isEqualTo: type)
          .where('isActive', isEqualTo: true) // ✅ ONLY fetch active posts of this type
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    final postDoc = postsRef.doc(postId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postDoc);
        if (!snapshot.exists) {
          throw Exception("Post does not exist");
        }

        final data = snapshot.data() as Map<String, dynamic>?;

        final currentLikes = List<String>.from(data?['likes'] ?? []);

        if (!currentLikes.contains(userId)) {
          transaction.update(postDoc, {
            'likes': FieldValue.arrayUnion([userId]),
          });
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    final postDoc = postsRef.doc(postId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postDoc);
        if (!snapshot.exists) {
          throw Exception("Post does not exist");
        }

        final data = snapshot.data() as Map<String, dynamic>?;

        final currentLikes = List<String>.from(data?['likes'] ?? []);

        if (currentLikes.contains(userId)) {
          transaction.update(postDoc, {
            'likes': FieldValue.arrayRemove([userId]),
          });
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> uploadImage(File image) async {
    try {
      final fileId = const Uuid().v4();
      final ref = FirebaseStorage.instance.ref('post_images/$fileId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }
}

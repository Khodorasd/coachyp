import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coachyp/features/posts/data/model/post_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'post_remote_data_source.dart';

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(PostModel post) async {
    final docRef = postsRef.doc(post.id);
    await docRef.set(post.toJson());
  }

  @override
  Future<List<PostModel>> fetchPosts() async {
    final snapshot = await postsRef.orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    await postsRef.doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<String> uploadImage(File image) async {
    final ref = FirebaseStorage.instance.ref('post_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
}
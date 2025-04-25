import 'package:coachyp/features/posts/domain/entities/post.dart';

abstract class PostRepository {
  Future<void> createPost(Post post);
  Future<List<Post>> fetchPosts();
  Future<void> likePost(String postId, String userId);
}

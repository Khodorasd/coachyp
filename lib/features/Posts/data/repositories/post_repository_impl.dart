import 'package:coachyp/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:coachyp/features/posts/data/model/post_model.dart';
import 'package:coachyp/features/posts/domain/entities/post.dart';
import 'package:coachyp/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remote;

  PostRepositoryImpl(this.remote);

  @override
  Future<void> createPost(Post post) {
    final model = PostModel(
      id: post.id,
      coachId: post.coachId,
      description: post.description,
      imageUrl: post.imageUrl,
      timestamp: post.timestamp,
      likes: post.likes,
    );
    return remote.createPost(model);
  }

  @override
  Future<List<Post>> fetchPosts() async {
    final models = await remote.fetchPosts(); // List<PostModel>
    return models.map<Post>((model) => Post(
      id: model.id,
      coachId: model.coachId,
      description: model.description,
      imageUrl: model.imageUrl,
      timestamp: model.timestamp,
      likes: model.likes,
    )).toList(); // ✅ Now returns List<Post>
  }

  @override
  Future<void> likePost(String postId, String userId) {
    return remote.likePost(postId, userId);
  }
}

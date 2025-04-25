import 'package:coachyp/features/posts/domain/entities/post.dart';
import 'package:coachyp/features/posts/domain/repositories/post_repository.dart';

class FetchPosts {
  final PostRepository repository;
  FetchPosts(this.repository);

  Future<List<Post>> call() {
    return repository.fetchPosts();
  }
}
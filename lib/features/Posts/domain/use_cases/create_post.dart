

import 'package:coachyp/features/posts/domain/entities/post.dart';
import 'package:coachyp/features/posts/domain/repositories/post_repository.dart';



class CreatePost {
  final PostRepository repository;
  CreatePost(this.repository);

  
  Future<void> call(Post post) {
    return repository.createPost(post);
  }
}

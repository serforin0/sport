import '../../../../core/result/result.dart';
import '../entities/post.dart';

abstract class FeedRepository {
  Future<Result<List<Post>>> getPosts({
    int page = 0,
    int limit = 10,
    String? userId,
    bool mySport = false,
  });

  Future<Result<Post>> getPostById(String id);
  Future<Result<bool>> likePost(String postId, String userId);
  Future<Result<Post>> addComment(String postId, String userId, String content);
  Future<Result<Post>> createPost(Post post);
}

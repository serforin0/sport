import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/errors/failures.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/feed/data/models/post_model.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final ApiClient apiClient;
  final SharedPreferences prefs;

  FeedRepositoryImpl(this.apiClient, this.prefs);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'cached_user';

  String? get _token => prefs.getString(_tokenKey);

  String get _currentUserId {
    final raw = prefs.getString(_userKey);
    if (raw == null) return '';
    try {
      final m = json.decode(raw) as Map<String, dynamic>;
      return m['id']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Options _bearerOptions() {
    final t = _token;
    if (t == null) {
      throw StateError('Sin token');
    }
    return Options(headers: {'Authorization': 'Bearer $t'});
  }

  String _mysqlDateTime(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }

  @override
  Future<Result<List<Post>>> getPosts({
    int page = 0,
    int limit = 10,
    String? userId,
    bool mySport = false,
  }) async {
    if (_token == null) {
      return Err(ValidationFailure('Inicia sesión para ver el feed'));
    }
    try {
      final queryParameters = <String, dynamic>{
        'page': page + 1,
        'per_page': limit,
      };
      if (userId != null) {
        queryParameters['user_id'] = userId;
      }
      if (mySport) {
        queryParameters['my_sport'] = 1;
      }

      final response = await apiClient.get(
        '/posts',
        queryParameters: queryParameters,
        options: _bearerOptions(),
      );

      final list = unwrapDataList(response.data);
      final uid = _currentUserId;
      final posts = list
          .whereType<Map>()
          .map((e) => PostModel.fromApi(Map<String, dynamic>.from(e), currentUserId: uid))
          .toList();
      return Ok(posts);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Post>> getPostById(String id) async {
    if (_token == null) {
      return Err(ValidationFailure('Inicia sesión'));
    }
    try {
      final response = await apiClient.get('/posts/$id', options: _bearerOptions());
      final map = unwrapDataMap(response.data) ??
          (response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null);
      if (map == null) {
        return Err(const NotFoundFailure('Post no encontrado'));
      }
      return Ok(PostModel.fromApi(map, currentUserId: _currentUserId));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> likePost(String postId, String userId) async {
    if (_token == null) {
      return Err(ValidationFailure('Inicia sesión'));
    }
    try {
      final detail = await apiClient.get('/posts/$postId', options: _bearerOptions());
      final map = unwrapDataMap(detail.data) ??
          (detail.data is Map ? Map<String, dynamic>.from(detail.data as Map) : null);
      if (map == null) {
        return Err(const NotFoundFailure());
      }
      final post = PostModel.fromApi(map, currentUserId: userId);
      if (post.isLikedBy(userId)) {
        await apiClient.delete('/posts/$postId/unlike', options: _bearerOptions());
      } else {
        await apiClient.post('/posts/$postId/like', options: _bearerOptions());
      }
      return const Ok(true);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Post>> addComment(String postId, String userId, String content) async {
    if (_token == null) {
      return Err(ValidationFailure('Inicia sesión'));
    }
    try {
      await apiClient.post(
        '/posts/$postId/comments',
        data: {'content': content},
        options: _bearerOptions(),
      );
      return getPostById(postId);
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Post>> createPost(Post post) async {
    if (_token == null) {
      return Err(ValidationFailure('Inicia sesión'));
    }
    try {
      // Usar FormData para permitir carga de archivos (Multipart)
      final formData = FormData.fromMap({
        'title': post.description.length > 50 
            ? '${post.description.substring(0, 47)}...' 
            : post.description,
        'body': post.description,
        'status': 'published',
        'published_at': _mysqlDateTime(DateTime.now()),
        if (post.location != null) 'location': post.location,
        if (post.eventName != null) 'event_name': post.eventName,
        if (post.postType != null) 'post_type': post.postType,
        if (post.activityUrl != null) 'activity_url': post.activityUrl,
      });

      // Adjuntar todas las imágenes locales seleccionadas.
      for (var i = 0; i < post.images.length; i++) {
        final path = post.images[i];
        if (path.startsWith('http')) continue;
        formData.files.add(MapEntry(
          'gallery[]',
          await MultipartFile.fromFile(path, filename: 'post_image_$i.jpg'),
        ));
      }

      final response = await apiClient.post(
        '/posts',
        data: formData,
        options: _bearerOptions(),
      );

      final map = unwrapDataMap(response.data) ??
          (response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null);
      if (map != null) {
        return Ok(PostModel.fromApi(map, currentUserId: _currentUserId));
      }
      final authorModel = post.author is UserModel
          ? post.author as UserModel
          : UserModel(
              id: post.author.id,
              email: post.author.email,
              name: post.author.name,
              photoUrl: post.author.photoUrl,
            );
      return Ok(PostModel(
        id: post.id,
        author: authorModel,
        description: post.description,
        images: post.images,
        videoUrl: post.videoUrl,
        createdAt: post.createdAt,
        likes: post.likes,
        comments: [
          for (final c in post.comments)
            CommentModel(
              id: c.id,
              author: c.author is UserModel
                  ? c.author as UserModel
                  : UserModel(
                      id: c.author.id,
                      email: c.author.email,
                      name: c.author.name,
                      photoUrl: c.author.photoUrl,
                    ),
              content: c.content,
              createdAt: c.createdAt,
            ),
        ],
        location: post.location,
        eventName: post.eventName,
      ));
    } catch (e) {
      return Err(ServerFailure(e.toString()));
    }
  }
}

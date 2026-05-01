import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../data/repositories/feed_repository_impl.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Post>>(() {
  return FeedNotifier();
});

class FeedNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(feedRepositoryProvider);
    final result = await repository.getPosts();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (posts) => posts,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(feedRepositoryProvider);
      final result = await repository.getPosts();
      return result.fold(
        (failure) => throw Exception(failure.message),
        (posts) => posts,
      );
    });
  }

  Future<void> likePost(String postId) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final repository = ref.read(feedRepositoryProvider);
    final result = await repository.likePost(postId, user.id);

    if (result.isSuccess) {
      await refresh();
    }
  }

  Future<void> createPost(Post post) async {
    final repository = ref.read(feedRepositoryProvider);
    final result = await repository.createPost(post);

    result.fold(
      (failure) => null,
      (newPost) {
        state.whenData((posts) {
          state = AsyncValue.data([newPost, ...posts]);
        });
      },
    );
  }

  Future<void> addComment(String postId, String content) async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final repository = ref.read(feedRepositoryProvider);
    final result = await repository.addComment(postId, user.id, content);

    if (result.isSuccess) {
      await refresh();
    }
  }
}

final userPostsProvider = FutureProvider.family<List<Post>, String>((ref, userId) async {
  final repository = ref.watch(feedRepositoryProvider);
  final result = await repository.getPosts(page: 0, limit: 20, userId: userId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) => posts,
  );
});

final getPostByIdProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final repository = ref.watch(feedRepositoryProvider);
  final result = await repository.getPostById(postId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (post) => post,
  );
});



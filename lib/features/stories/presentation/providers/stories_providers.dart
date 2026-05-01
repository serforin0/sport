import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/stories_remote_datasource.dart';
import '../../domain/entities/story.dart';

final storiesRemoteDataSourceProvider = Provider<StoriesRemoteDataSource>((ref) {
  return StoriesRemoteDataSource(ref.watch(apiClientProvider));
});

List<Story> _markOwn(List<Story> raw, String? myId) {
  if (myId == null || myId.isEmpty) return raw;
  return [
    for (final s in raw)
      Story(
        id: s.id,
        ownerUserId: s.ownerUserId,
        displayName: s.displayName,
        avatarUrl: s.avatarUrl,
        mediaUrl: s.mediaUrl,
        type: s.type,
        isOwn: s.isOwn || s.ownerUserId == myId,
      ),
  ];
}

final storiesProvider = FutureProvider<List<Story>>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final token = prefs.getString('auth_token');
  if (token == null) return [];
  final ds = ref.watch(storiesRemoteDataSourceProvider);
  final myId = ref.watch(authControllerProvider).valueOrNull?.id;
  final list = await ds.fetchStories(token);
  return _markOwn(list, myId);
});

final storiesNotifierProvider =
    AsyncNotifierProvider<StoriesNotifier, List<Story>>(StoriesNotifier.new);

class StoriesNotifier extends AsyncNotifier<List<Story>> {
  @override
  Future<List<Story>> build() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    if (token == null) return [];
    final myId = ref.read(authControllerProvider).valueOrNull?.id;
    final raw = await ref.read(storiesRemoteDataSourceProvider).fetchStories(token);
    return _markOwn(raw, myId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.read(sharedPreferencesProvider);
      final token = prefs.getString('auth_token');
      if (token == null) return <Story>[];
      final myId = ref.read(authControllerProvider).valueOrNull?.id;
      final raw = await ref.read(storiesRemoteDataSourceProvider).fetchStories(token);
      return _markOwn(raw, myId);
    });
  }

  Future<void> createStory({String? mediaUrl, String? filePath, required String type}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    if (token == null) return;
    await ref.read(storiesRemoteDataSourceProvider).createStory(
          token,
          mediaUrl: mediaUrl,
          filePath: filePath,
          type: type,
        );
    await refresh();
  }

}

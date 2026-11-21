import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/domain/repositories/feed_repository.dart';
import 'package:sport/features/feed/presentation/pages/feed_page.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';
import 'package:sport/features/news/domain/entities/news_article.dart';
import 'package:sport/features/news/presentation/providers/news_providers.dart';
import 'package:sport/features/results/domain/entities/match_result.dart';
import 'package:sport/features/results/presentation/providers/results_providers.dart';
import 'package:sport/features/stories/domain/entities/story.dart';
import 'package:sport/features/stories/presentation/providers/stories_providers.dart';
import '../../../../helpers/test_prefs.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class SeededFeedNotifier extends FeedNotifier {
  SeededFeedNotifier(this._posts);
  final List<Post> _posts;

  @override
  Future<List<Post>> build() async => _posts;
}

void main() {
  late MockFeedRepository feed;
  late MockAuthRepository auth;
  const user = User(
    id: '1',
    email: 't@test.com',
    name: 'Test',
    mainSport: 'fútbol',
    sportId: 's1',
  );
  final posts = [
    Post(
      id: '1',
      author: user,
      description: 'Post feed',
      createdAt: DateTime(2026, 1, 1),
      likes: const [],
      comments: const [],
    ),
  ];

  setUp(() {
    feed = MockFeedRepository();
    auth = MockAuthRepository();
    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(
      () => feed.getPosts(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        userId: any(named: 'userId'),
        mySport: any(named: 'mySport'),
      ),
    ).thenAnswer((_) async => Ok(posts));
  });

  testWidgets('tap_mi_deporte_y_todos_los_deportes_cambian_scope', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final prefs = createMockPrefs();
    final authController = AuthController(auth)..state = const AsyncValue.data(user);
    late String scopeRead;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          feedRepositoryProvider.overrideWithValue(feed),
          authRepositoryProvider.overrideWithValue(auth),
          authControllerProvider.overrideWith((ref) => authController),
          feedProvider.overrideWith(() => SeededFeedNotifier(posts)),
          storiesProvider.overrideWith((ref) async => <Story>[]),
          sportsNewsProvider.overrideWith((ref) async => <NewsArticle>[]),
          recentResultsProvider.overrideWith((ref) async => <MatchResult>[]),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              scopeRead = ref.watch(feedSportScopeProvider);
              return const FeedPage();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Mi deporte'), findsOneWidget);
    expect(find.text('Todos los deportes'), findsOneWidget);
    expect(scopeRead, 'all');

    await tester.tap(find.textContaining('Mi deporte'));
    await tester.pumpAndSettle();
    expect(scopeRead, 'my_sport');

    await tester.tap(find.text('Todos los deportes'));
    await tester.pumpAndSettle();
    expect(scopeRead, 'all');
  });
}

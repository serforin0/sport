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
  late MockFeedRepository mockFeedRepository;
  late MockAuthRepository mockAuthRepository;
  const tUser = User(id: '1', email: 'test@test.com', name: 'Test User');

  final tPosts = [
    Post(
      id: '1',
      author: tUser,
      description: 'Test post 1',
      createdAt: DateTime.now(),
      likes: const [],
      comments: const [],
    ),
  ];

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const Ok(tUser));
    when(() => mockFeedRepository.getPosts()).thenAnswer((_) async => Ok(tPosts));
  });

  testWidgets('Muestra posts del feed', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final prefs = createMockPrefs();
    final authController = AuthController(mockAuthRepository)
      ..state = const AsyncValue.data(tUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          feedRepositoryProvider.overrideWithValue(mockFeedRepository),
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          authControllerProvider.overrideWith((ref) => authController),
          feedProvider.overrideWith(() => SeededFeedNotifier(tPosts)),
          storiesProvider.overrideWith((ref) async => <Story>[]),
          sportsNewsProvider.overrideWith((ref) async => <NewsArticle>[]),
          recentResultsProvider.overrideWith((ref) async => <MatchResult>[]),
        ],
        child: const MaterialApp(home: FeedPage()),
      ),
    );
    await tester.pumpAndSettle();

    final postText = find.text('Test post 1', skipOffstage: false);
    if (postText.evaluate().isEmpty) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
      await tester.pumpAndSettle();
    }
    expect(find.text('Test post 1', skipOffstage: false), findsOneWidget);
  });
}

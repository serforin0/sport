import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/chat/domain/repositories/chat_repository.dart';
import 'package:sport/features/chat/presentation/providers/chat_providers.dart';
import 'package:sport/features/connections/data/datasources/connections_remote_datasource.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';
import 'package:sport/features/feed/domain/repositories/feed_repository.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';
import 'package:sport/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:sport/features/jobs/presentation/providers/jobs_providers.dart';
import 'package:sport/features/news/domain/entities/news_article.dart';
import 'package:sport/features/news/presentation/providers/news_providers.dart';
import 'package:sport/features/onboarding/presentation/pages/role_guide_page.dart';
import 'package:sport/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:sport/features/people/domain/people_list_user.dart';
import 'package:sport/features/results/domain/entities/match_result.dart';
import 'package:sport/features/results/presentation/providers/results_providers.dart';
import 'package:sport/features/search/presentation/providers/search_providers.dart';
import 'package:sport/features/shell/main_shell.dart';
import 'package:sport/features/stories/domain/entities/story.dart';
import 'package:sport/features/stories/presentation/providers/stories_providers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFeedRepository extends Mock implements FeedRepository {}

class MockJobsRepository extends Mock implements JobsRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockConnectionsRemoteDataSource extends Mock
    implements ConnectionsRemoteDataSource {}

/// Mirrors `_PostAuthHome` gate in main.dart for isolated certification.
class _PostAuthGateUnderTest extends ConsumerWidget {
  const _PostAuthGateUnderTest();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guideDone = ref.watch(roleGuideDoneProvider);
    return guideDone.when(
      data: (done) => done ? const MainShell() : const RoleGuidePage(),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const MainShell(),
    );
  }
}

void main() {
  const user = User(
    id: 'u1',
    email: 'a@test.com',
    name: 'Ana',
    profileType: 'athlete',
  );

  late MockAuthRepository auth;
  late MockFeedRepository feed;
  late MockJobsRepository jobs;
  late MockChatRepository chat;
  late MockConnectionsRemoteDataSource connections;

  setUp(() {
    auth = MockAuthRepository();
    feed = MockFeedRepository();
    jobs = MockJobsRepository();
    chat = MockChatRepository();
    connections = MockConnectionsRemoteDataSource();

    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(
      () => feed.getPosts(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        userId: any(named: 'userId'),
        mySport: any(named: 'mySport'),
      ),
    ).thenAnswer((_) async => const Ok([]));
    when(() => jobs.getJobs()).thenAnswer((_) async => const Ok([]));
    when(() => chat.getConversations()).thenAnswer((_) async => []);
    when(
      () => connections.fetchAcceptedConnections(
        any(),
        viewerId: any(named: 'viewerId'),
      ),
    ).thenAnswer((_) async => []);
    when(() => connections.fetchIncoming(any())).thenAnswer((_) async => []);
  });

  List<Override> overrides({
    required SharedPreferences prefs,
    required AuthController ctrl,
    required bool guideDone,
  }) =>
      [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sharedPrefsInitProvider.overrideWith((ref) async => prefs),
        authRepositoryProvider.overrideWithValue(auth),
        authControllerProvider.overrideWith((ref) => ctrl),
        roleGuideDoneProvider.overrideWith((ref) async => guideDone),
        feedRepositoryProvider.overrideWithValue(feed),
        jobsRepositoryProvider.overrideWithValue(jobs),
        chatRepositoryProvider.overrideWithValue(chat),
        connectionsRemoteDataSourceProvider.overrideWithValue(connections),
        peopleSuggestionsProvider.overrideWith(
          (ref) async => <PeopleListUser>[],
        ),
        acceptedConnectionsProvider.overrideWith((ref) async => []),
        storiesProvider.overrideWith((ref) async => <Story>[]),
        sportsNewsProvider.overrideWith((ref) async => <NewsArticle>[]),
        recentResultsProvider.overrideWith((ref) async => <MatchResult>[]),
      ];

  testWidgets('role_guide_done_false_muestra_RoleGuidePage', (tester) async {
    SharedPreferences.setMockInitialValues({'role_guide_done': false});
    final prefs = await SharedPreferences.getInstance();
    final ctrl = AuthController(auth)..state = const AsyncValue.data(user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(prefs: prefs, ctrl: ctrl, guideDone: false),
        child: const MaterialApp(home: _PostAuthGateUnderTest()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RoleGuidePage), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);
    expect(find.byType(MainShell), findsNothing);
  });

  testWidgets('role_guide_done_true_muestra_MainShell', (tester) async {
    SharedPreferences.setMockInitialValues({'role_guide_done': true});
    final prefs = await SharedPreferences.getInstance();
    final ctrl = AuthController(auth)..state = const AsyncValue.data(user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(prefs: prefs, ctrl: ctrl, guideDone: true),
        child: const MaterialApp(home: _PostAuthGateUnderTest()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(RoleGuidePage), findsNothing);
    expect(find.text('Inicio'), findsWidgets);
  });
}

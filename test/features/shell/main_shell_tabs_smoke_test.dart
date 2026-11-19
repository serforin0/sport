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
import 'package:sport/features/people/domain/people_list_user.dart';
import 'package:sport/features/search/presentation/providers/search_providers.dart';
import 'package:sport/features/shell/main_shell.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockJobsRepository extends Mock implements JobsRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockConnectionsRemoteDataSource extends Mock
    implements ConnectionsRemoteDataSource {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockFeedRepository feed;
  late MockAuthRepository auth;
  late MockJobsRepository jobs;
  late MockChatRepository chat;
  late MockConnectionsRemoteDataSource connections;
  late MockSharedPreferences prefs;

  setUp(() {
    feed = MockFeedRepository();
    auth = MockAuthRepository();
    jobs = MockJobsRepository();
    chat = MockChatRepository();
    connections = MockConnectionsRemoteDataSource();
    prefs = MockSharedPreferences();

    const user = User(id: 'u1', email: 'a@test.com', name: 'Ana');
    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(
      () => feed.getPosts(page: any(named: 'page'), limit: any(named: 'limit')),
    ).thenAnswer((_) async => const Ok([]));
    when(() => jobs.getJobs()).thenAnswer((_) async => const Ok([]));
    when(() => chat.getConversations()).thenAnswer((_) async => []);
    when(() => prefs.getString(any())).thenReturn('tok');
    when(() => prefs.getString('cached_user')).thenReturn('{"id":"u1"}');
    when(
      () => connections.fetchAcceptedConnections(
        any(),
        viewerId: any(named: 'viewerId'),
      ),
    ).thenAnswer((_) async => []);
    when(() => connections.fetchIncoming(any())).thenAnswer((_) async => []);
  });

  testWidgets('shell monta tabs Inicio Personas Trabajo Eventos', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(auth),
          feedRepositoryProvider.overrideWithValue(feed),
          jobsRepositoryProvider.overrideWithValue(jobs),
          chatRepositoryProvider.overrideWithValue(chat),
          connectionsRemoteDataSourceProvider.overrideWithValue(connections),
          peopleSuggestionsProvider.overrideWith(
            (ref) async => <PeopleListUser>[],
          ),
          acceptedConnectionsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: MainShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Eventos'), findsOneWidget);
    expect(find.text('Chat'), findsNothing);

    final peopleIcon = find.byIcon(Icons.person_search_outlined);
    if (peopleIcon.evaluate().isNotEmpty) {
      await tester.tap(peopleIcon.first);
      await tester.pumpAndSettle();
    }

    final eventsIcon = find.byIcon(Icons.event_outlined);
    if (eventsIcon.evaluate().isNotEmpty) {
      await tester.tap(eventsIcon.first);
      await tester.pumpAndSettle();
    }
  });
}

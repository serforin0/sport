import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/connections/data/datasources/connections_remote_datasource.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';
import 'package:sport/features/people/domain/people_list_user.dart';
import 'package:sport/features/people/presentation/pages/people_page.dart';
import 'package:sport/features/search/presentation/providers/search_providers.dart';

class MockConnectionsRemoteDataSource extends Mock
    implements ConnectionsRemoteDataSource {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockConnectionsRemoteDataSource ds;
  late MockSharedPreferences prefs;

  final suggestion = PeopleListUser(
    user: const UserModel(id: 'u2', email: 'peer@test.com', name: 'Camila'),
    detailLine: 'Atleta · Fútbol',
  );

  setUp(() {
    ds = MockConnectionsRemoteDataSource();
    prefs = MockSharedPreferences();
    when(() => prefs.getString('auth_token')).thenReturn('tok');
    when(() => prefs.getString('cached_user')).thenReturn('{"id":"u1"}');
    when(() => ds.sendRequest('tok', 'u2')).thenAnswer((_) async {});
    when(
      () => ds.fetchAcceptedConnections('tok', viewerId: any(named: 'viewerId')),
    ).thenAnswer((_) async => []);
    when(() => ds.fetchIncoming('tok')).thenAnswer((_) async => []);
  });

  testWidgets('flujo conectar desde Personas envía solicitud', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          connectionsRemoteDataSourceProvider.overrideWithValue(ds),
          peopleSuggestionsProvider.overrideWith((ref) async => [suggestion]),
          acceptedConnectionsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: PeoplePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camila'), findsOneWidget);
    await tester.tap(find.text('Conectar'));
    await tester.pumpAndSettle();

    verify(() => ds.sendRequest('tok', 'u2')).called(1);
    expect(find.textContaining('Solicitud enviada'), findsOneWidget);
  });
}

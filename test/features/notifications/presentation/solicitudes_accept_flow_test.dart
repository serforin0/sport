import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/connections/data/datasources/connections_remote_datasource.dart';
import 'package:sport/features/connections/domain/entities/pending_connection.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';
import 'package:sport/features/notifications/presentation/pages/solicitudes_page.dart';

class MockConnectionsRemoteDataSource extends Mock
    implements ConnectionsRemoteDataSource {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockConnectionsRemoteDataSource ds;
  late MockSharedPreferences prefs;

  const pending = PendingConnection(
    connectionId: 'c1',
    userId: 'u2',
    name: 'Camila Soto',
    roleLabel: 'Atleta',
  );

  setUp(() {
    ds = MockConnectionsRemoteDataSource();
    prefs = MockSharedPreferences();
    when(() => prefs.getString('auth_token')).thenReturn('tok');
    when(() => ds.fetchIncoming('tok')).thenAnswer((_) async => [pending]);
    when(() => ds.accept('tok', 'c1')).thenAnswer((_) async {});
  });

  testWidgets('flujo aceptar solicitud de conexión', (tester) async {
    var accepted = false;
    when(() => ds.fetchIncoming('tok')).thenAnswer((_) async {
      return accepted ? <PendingConnection>[] : [pending];
    });
    when(() => ds.accept('tok', 'c1')).thenAnswer((_) async {
      accepted = true;
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          connectionsRemoteDataSourceProvider.overrideWithValue(ds),
        ],
        child: const MaterialApp(home: SolicitudesPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Camila Soto'), findsOneWidget);
    expect(find.text('Aceptar'), findsOneWidget);

    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();

    verify(() => ds.accept('tok', 'c1')).called(1);
    expect(find.textContaining('Conectado con Camila Soto'), findsOneWidget);
    expect(find.text('Sin solicitudes pendientes'), findsOneWidget);
  });
}

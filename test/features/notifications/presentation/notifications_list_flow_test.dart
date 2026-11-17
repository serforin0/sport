import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/connections/data/datasources/connections_remote_datasource.dart';
import 'package:sport/features/connections/presentation/providers/connections_providers.dart';
import 'package:sport/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:sport/features/notifications/domain/entities/notification.dart';
import 'package:sport/features/notifications/presentation/pages/notifications_page.dart';
import 'package:sport/features/notifications/presentation/providers/notifications_provider.dart';

class MockNotificationsRemoteDataSource extends Mock
    implements NotificationsRemoteDataSource {}

class MockConnectionsRemoteDataSource extends Mock
    implements ConnectionsRemoteDataSource {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockNotificationsRemoteDataSource notifDs;
  late MockConnectionsRemoteDataSource connDs;
  late MockSharedPreferences prefs;

  setUp(() {
    notifDs = MockNotificationsRemoteDataSource();
    connDs = MockConnectionsRemoteDataSource();
    prefs = MockSharedPreferences();
    when(() => prefs.getString('auth_token')).thenReturn('tok');
    when(() => connDs.fetchIncoming('tok')).thenAnswer((_) async => []);
    when(() => notifDs.fetchNotifications()).thenAnswer(
      (_) async => [
        AppNotification(
          id: 'n1',
          authorName: 'Diego',
          type: NotificationType.like,
          createdAt: DateTime.now(),
          body: 'Le gustó tu publicación',
        ),
      ],
    );
  });

  testWidgets('flujo lista de notificaciones', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationsRemoteDataSourceProvider.overrideWithValue(notifDs),
          connectionsRemoteDataSourceProvider.overrideWithValue(connDs),
        ],
        child: const MaterialApp(home: NotificationsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Hoy'), findsOneWidget);
    expect(
      find.textContaining('Diego', findRichText: true),
      findsOneWidget,
    );
  });
}

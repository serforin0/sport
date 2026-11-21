import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/scout_metrics/data/repositories/scout_metrics_repository.dart';
import 'package:sport/features/scout_metrics/domain/entities/scout_metric.dart';
import 'package:sport/features/scout_metrics/presentation/pages/scout_metrics_page.dart';
import 'package:sport/features/scout_metrics/presentation/providers/scout_metrics_providers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockScoutMetricsRepository extends Mock implements ScoutMetricsRepository {}

void main() {
  const user = User(
    id: 'u1',
    email: 'athlete@hubsport.test',
    name: 'Luis Peña',
    mainSport: 'béisbol',
    sportId: 'sport-1',
    sportLockedAt: '2026-11-19T00:00:00.000000Z',
    heightCm: 185,
    weightKg: 82.5,
  );

  const snapshot = ScoutMetricsSnapshot(
    definitions: [
      SportMetricDefinition(
        id: 'def-avg',
        sportId: 'sport-1',
        metricGroup: 'Bateo',
        key: 'avg',
        label: 'AVG',
      ),
    ],
    values: [
      AthleteMetricValue(
        id: 'm1',
        definitionId: 'def-avg',
        valueNumeric: 0.312,
        verificationStatus: 'coach_verified',
      ),
    ],
    empty: false,
    invite: null,
  );

  testWidgets('ScoutMetricsPage muestra físico, métricas y deporte fijo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final authRepo = MockAuthRepository();
    final scoutRepo = MockScoutMetricsRepository();
    when(() => authRepo.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(() => scoutRepo.listVideos()).thenAnswer((_) async => const Ok([]));
    when(() => scoutRepo.loadForSport(any())).thenAnswer(
      (_) async => const Ok(snapshot),
    );

    final authController = AuthController(authRepo)
      ..state = const AsyncValue.data(user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          authControllerProvider.overrideWith((ref) => authController),
          scoutMetricsRepositoryProvider.overrideWithValue(scoutRepo),
          scoutMetricsProvider('sport-1').overrideWith((ref) async => snapshot),
        ],
        child: const MaterialApp(home: ScoutMetricsPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Perfil scout'), findsOneWidget);
    expect(find.text('Perfil físico'), findsOneWidget);
    expect(find.textContaining('Deporte fijo'), findsOneWidget);
    expect(find.text('AVG'), findsOneWidget);
    expect(find.text('Guardar perfil scout'), findsOneWidget);
    expect(find.text('Entrenador'), findsOneWidget);
  });
}

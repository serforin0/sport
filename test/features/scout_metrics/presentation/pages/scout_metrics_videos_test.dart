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

class MockScoutMetricsRepository extends Mock
    implements ScoutMetricsRepository {}

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
    values: [],
    empty: true,
  );

  late MockAuthRepository authRepo;
  late MockScoutMetricsRepository scoutRepo;
  late AuthController authController;

  setUp(() {
    authRepo = MockAuthRepository();
    scoutRepo = MockScoutMetricsRepository();
    when(() => authRepo.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(() => authRepo.getProfile(any())).thenAnswer((_) async => const Ok(user));
    when(() => scoutRepo.listVideos()).thenAnswer(
      (_) async => const Ok([
        {'id': 'vid-1', 'title': 'Highlights 2026', 'video_url': 'https://x/v.mp4'},
      ]),
    );
    when(
      () => scoutRepo.addVideo(
        title: any(named: 'title'),
        videoUrl: any(named: 'videoUrl'),
        kind: any(named: 'kind'),
      ),
    ).thenAnswer((_) async => const Ok(true));
    when(() => scoutRepo.deleteVideo(any())).thenAnswer((_) async => const Ok(true));
    when(
      () => scoutRepo.updatePhysicalProfile(
        userId: any(named: 'userId'),
        heightCm: any(named: 'heightCm'),
        weightKg: any(named: 'weightKg'),
        wingspanCm: any(named: 'wingspanCm'),
        laterality: any(named: 'laterality'),
        currentTeam: any(named: 'currentTeam'),
      ),
    ).thenAnswer((_) async => const Ok(true));
    when(() => scoutRepo.upsertMetrics(any())).thenAnswer((_) async => const Ok(true));
    authController = AuthController(authRepo)..state = const AsyncValue.data(user);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('tap_eliminar_video_llama_deleteVideo', (tester) async {
    await pumpPage(tester);

    expect(find.text('Highlights 2026'), findsOneWidget);
    await tester.ensureVisible(find.byIcon(Icons.delete_outline));
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    verify(() => scoutRepo.deleteVideo('vid-1')).called(1);
    expect(find.text('Highlights 2026'), findsNothing);
  });

  testWidgets('tap_agregar_video_llama_addVideo_y_recarga', (tester) async {
    when(() => scoutRepo.listVideos()).thenAnswer((_) async => const Ok([]));
    await pumpPage(tester);

    await tester.scrollUntilVisible(
      find.text('Agregar video'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    final fields = find.byType(TextFormField);
    // Title and URL are near the bottom among many fields — enter by scrolling to labels
    await tester.enterText(
      find.widgetWithText(TextFormField, '').first,
      'Clip nuevo',
    );

    // Find title/url via ancestor of label Text
    final titleLabel = find.text('Título del video');
    final urlLabel = find.text('URL del video');
    expect(titleLabel, findsOneWidget);
    expect(urlLabel, findsOneWidget);

    // Enter into the TextFormField following each label by finding nearby fields
    final allFields = find.byType(TextFormField);
    // Last two dedicated video fields are typically near end
    await tester.enterText(allFields.at(allFields.evaluate().length - 2), 'Clip nuevo');
    await tester.enterText(
      allFields.at(allFields.evaluate().length - 1),
      'https://example.test/new.mp4',
    );
    await tester.pump();

    when(() => scoutRepo.listVideos()).thenAnswer(
      (_) async => const Ok([
        {'id': 'vid-2', 'title': 'Clip nuevo', 'video_url': 'https://example.test/new.mp4'},
      ]),
    );

    await tester.tap(find.text('Agregar video'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    verify(
      () => scoutRepo.addVideo(
        title: 'Clip nuevo',
        videoUrl: 'https://example.test/new.mp4',
        kind: any(named: 'kind'),
      ),
    ).called(1);
    verify(() => scoutRepo.listVideos()).called(greaterThanOrEqualTo(2));
  });

  testWidgets('tap_guardar_perfil_scout_upsert_y_fisico', (tester) async {
    when(() => scoutRepo.listVideos()).thenAnswer((_) async => const Ok([]));
    await pumpPage(tester);

    await tester.scrollUntilVisible(
      find.text('Guardar perfil scout'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Guardar perfil scout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verify(
      () => scoutRepo.updatePhysicalProfile(
        userId: 'u1',
        heightCm: any(named: 'heightCm'),
        weightKg: any(named: 'weightKg'),
        wingspanCm: any(named: 'wingspanCm'),
        laterality: any(named: 'laterality'),
        currentTeam: any(named: 'currentTeam'),
      ),
    ).called(1);
    expect(find.text('Perfil scout actualizado'), findsOneWidget);
  });
}

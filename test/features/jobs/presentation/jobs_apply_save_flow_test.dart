import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:sport/features/jobs/presentation/pages/job_detail_page.dart';
import 'package:sport/features/jobs/presentation/providers/jobs_providers.dart';

class MockJobsRepository extends Mock implements JobsRepository {}

void main() {
  late MockJobsRepository jobs;

  final offer = JobOffer(
    id: 'j1',
    title: 'Entrenador juvenil',
    description: 'Buscamos coach con experiencia.',
    company: 'Club Horizonte',
    location: 'Santiago',
    modality: 'Jornada completa',
    experienceLevel: 'Mid',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    jobs = MockJobsRepository();
    when(() => jobs.saveJob('j1')).thenAnswer((_) async => const Ok(true));
    when(
      () => jobs.applyToJob('j1', any()),
    ).thenAnswer((_) async => const Ok(true));
  });

  Widget pumpDetail() {
    return ProviderScope(
      overrides: [jobsRepositoryProvider.overrideWithValue(jobs)],
      child: MaterialApp(home: JobDetailPage(job: offer)),
    );
  }

  testWidgets('flujo guardar y aplicar empleo', (tester) async {
    await tester.pumpWidget(pumpDetail());
    await tester.pumpAndSettle();

    expect(find.text('Entrenador juvenil'), findsOneWidget);
    expect(find.text('Aplicar'), findsOneWidget);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    verify(() => jobs.saveJob('j1')).called(1);
    expect(find.text('Guardado'), findsOneWidget);

    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    expect(find.text('Aplicar al empleo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Me interesa el puesto');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    verify(() => jobs.applyToJob('j1', 'Me interesa el puesto')).called(1);
    expect(find.text('Aplicación enviada'), findsOneWidget);
    expect(find.text('Cancelar aplicación'), findsOneWidget);
  });
}

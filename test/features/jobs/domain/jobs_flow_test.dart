import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/jobs/domain/repositories/jobs_repository.dart';

class MockJobsRepository extends Mock implements JobsRepository {}

void main() {
  late MockJobsRepository jobs;

  final offer = JobOffer(
    id: 'j1',
    title: 'Entrenador juvenil',
    description: 'Club Horizonte',
    company: 'Club Horizonte',
    location: 'Santiago',
    modality: 'Jornada completa',
    experienceLevel: 'Mid',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    jobs = MockJobsRepository();
  });

  test('flujo listar → detalle → aplicar → guardar', () async {
    when(() => jobs.getJobs()).thenAnswer((_) async => Ok([offer]));
    when(() => jobs.getJobById('j1')).thenAnswer((_) async => Ok(offer));
    when(
      () => jobs.applyToJob('j1', 'Me interesa'),
    ).thenAnswer((_) async => const Ok(true));
    when(() => jobs.saveJob('j1')).thenAnswer((_) async => const Ok(true));
    when(() => jobs.getMyApplications()).thenAnswer(
      (_) async => Ok([offer.copyWith(hasApplied: true)]),
    );
    when(() => jobs.getSavedJobs()).thenAnswer(
      (_) async => Ok([offer.copyWith(isSaved: true)]),
    );

    final list = await jobs.getJobs();
    expect(list.isSuccess, isTrue);
    expect((list as Ok<List<JobOffer>>).value.single.id, 'j1');

    final detail = await jobs.getJobById('j1');
    expect((detail as Ok<JobOffer>).value.title, 'Entrenador juvenil');

    final applied = await jobs.applyToJob('j1', 'Me interesa');
    expect(applied.isSuccess, isTrue);

    final saved = await jobs.saveJob('j1');
    expect(saved.isSuccess, isTrue);

    final applications = await jobs.getMyApplications();
    expect((applications as Ok<List<JobOffer>>).value.single.hasApplied, isTrue);

    final savedList = await jobs.getSavedJobs();
    expect((savedList as Ok<List<JobOffer>>).value.single.isSaved, isTrue);
  });
}

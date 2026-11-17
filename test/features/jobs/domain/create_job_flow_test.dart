import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/jobs/domain/repositories/jobs_repository.dart';

class MockJobsRepository extends Mock implements JobsRepository {}

void main() {
  test('flujo crear oferta de empleo', () async {
    final jobs = MockJobsRepository();
    final created = JobOffer(
      id: 'j2',
      title: 'Fisioterapeuta',
      description: 'Clínica deportiva',
      company: 'Rehab Pro',
      location: 'SD',
      modality: 'Full',
      experienceLevel: 'Senior',
      createdAt: DateTime(2026, 1, 1),
      isOwner: true,
    );

    when(() => jobs.createJob(any())).thenAnswer((_) async => Ok(created));
    when(() => jobs.getMyOffers()).thenAnswer((_) async => Ok([created]));

    final result = await jobs.createJob({
      'title': 'Fisioterapeuta',
      'company': 'Rehab Pro',
      'location': 'SD',
      'contract_type': 'Full',
      'description': 'Clínica deportiva',
      'application_type': 'simple',
    });

    expect(result.isSuccess, isTrue);
    expect((result as Ok<JobOffer>).value.id, 'j2');

    final mine = await jobs.getMyOffers();
    expect((mine as Ok<List<JobOffer>>).value.single.isOwner, isTrue);
  });
}

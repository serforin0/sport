import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/search/data/search_remote_datasource.dart';

class MockSearchRemoteDataSource extends Mock implements SearchRemoteDataSource {}

void main() {
  late MockSearchRemoteDataSource search;

  setUp(() {
    search = MockSearchRemoteDataSource();
  });

  test('flujo búsqueda por query retorna usuarios y empleos', () async {
    const filters = SearchFilters(query: 'Camila');
    const users = [
      UserModel(id: 'u2', email: 'c@test.com', name: 'Camila'),
    ];
    final jobs = [
      JobOffer(
        id: 'j1',
        title: 'Coach Camila Team',
        description: 'desc',
        company: 'Club',
        location: 'SD',
        modality: 'Full',
        experienceLevel: 'Mid',
        createdAt: DateTime(2026, 1, 1),
      ),
    ];

    when(
      () => search.search('tok', filters, currentUserId: 'u1'),
    ).thenAnswer(
      (_) async => (
        users: users,
        posts: <Post>[],
        opportunities: jobs,
        events: <SportEvent>[],
        sponsorships: <SponsorshipResult>[],
      ),
    );

    final result = await search.search('tok', filters, currentUserId: 'u1');
    expect(result.users.single.name, 'Camila');
    expect(result.opportunities.single.id, 'j1');
  });
}

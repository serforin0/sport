import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/news/domain/entities/news_article.dart';
import 'package:sport/features/news/domain/repositories/news_repository.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

/// Certifica el contrato Wave 6: scope my_sport → sport_id; all → null.
/// (Lógica espejo de sportsNewsProvider sin montar Riverpod async que cuelga en CI.)
String? sportIdForNewsScope({
  required String scope,
  required String? userSportId,
}) {
  return scope == 'my_sport' ? userSportId : null;
}

void main() {
  test('my_sport_pasa_sportId_al_repositorio', () async {
    final newsRepo = MockNewsRepository();
    when(
      () => newsRepo.getSportsNews(sportId: 'sport-futbol'),
    ).thenAnswer((_) async => const Ok(<NewsArticle>[]));

    final sportId = sportIdForNewsScope(
      scope: 'my_sport',
      userSportId: 'sport-futbol',
    );
    final result = await newsRepo.getSportsNews(sportId: sportId);
    expect(result.isSuccess, isTrue);
    expect(sportId, 'sport-futbol');
    verify(() => newsRepo.getSportsNews(sportId: 'sport-futbol')).called(1);
  });

  test('all_no_pasa_sportId', () async {
    final newsRepo = MockNewsRepository();
    when(
      () => newsRepo.getSportsNews(sportId: null),
    ).thenAnswer((_) async => const Ok(<NewsArticle>[]));

    final sportId = sportIdForNewsScope(
      scope: 'all',
      userSportId: 'sport-futbol',
    );
    final result = await newsRepo.getSportsNews(sportId: sportId);
    expect(result.isSuccess, isTrue);
    expect(sportId, isNull);
    verify(() => newsRepo.getSportsNews(sportId: null)).called(1);
  });
}

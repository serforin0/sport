import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/news/data/datasources/news_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  test('getSportsNews_con_sportId_envia_query_sport_id', () async {
    final api = MockApiClient();
    final ds = NewsRemoteDataSourceImpl(api);

    when(
      () => api.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sport/news'),
        data: {'data': []},
      ),
    );

    await ds.getSportsNews(sportId: 'sport-1');

    final q = verify(
      () => api.get(
        any(),
        queryParameters: captureAny(named: 'queryParameters'),
      ),
    ).captured.single as Map;

    expect(q['sport_id'], 'sport-1');
  });
}

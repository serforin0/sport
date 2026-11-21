import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/feed/data/repositories/feed_repository_impl.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late FeedRepositoryImpl repository;
  late MockApiClient mockApi;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockApi = MockApiClient();
    mockPrefs = MockSharedPreferences();
    repository = FeedRepositoryImpl(mockApi, mockPrefs);
    when(() => mockPrefs.getString('auth_token')).thenReturn('tok');
    when(() => mockPrefs.getString('cached_user')).thenReturn(
      '{"id":"u1","email":"a@test.com","name":"Ana"}',
    );
  });

  test('getPosts_mySport_true_envia_query_my_sport', () async {
    when(
      () => mockApi.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/posts'),
        data: {'data': []},
      ),
    );

    final result = await repository.getPosts(mySport: true);
    expect(result.isSuccess, isTrue);

    final captured = verify(
      () => mockApi.get(
        '/posts',
        queryParameters: captureAny(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(captured['my_sport'], 1);
  });

  test('getPosts_mySport_false_no_envia_my_sport', () async {
    when(
      () => mockApi.get(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/posts'),
        data: {'data': []},
      ),
    );

    await repository.getPosts(mySport: false);
    final captured = verify(
      () => mockApi.get(
        '/posts',
        queryParameters: captureAny(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).captured.single as Map<String, dynamic>;

    expect(captured.containsKey('my_sport'), isFalse);
  });
}

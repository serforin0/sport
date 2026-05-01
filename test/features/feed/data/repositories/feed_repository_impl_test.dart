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
    when(() => mockPrefs.getString('auth_token')).thenReturn(null);
  });

  group('getPosts', () {
    test('sin token de sesión devuelve fallo', () async {
      final result = await repository.getPosts();
      expect(result.isFailure, true);
      verifyNever(() => mockApi.get(any(), queryParameters: any(named: 'queryParameters')));
    });
  });
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/auth/data/repositories/auth_repository_impl.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthRepositoryImpl repository;
  late MockSharedPreferences mockSharedPreferences;
  late MockApiClient mockApiClient;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockApiClient = MockApiClient();
    repository = AuthRepositoryImpl(mockSharedPreferences, mockApiClient);
  });

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('signInWithEmailAndPassword', () {
    const tEmail = 'yordyespinossa@gmail.com';
    const tPassword = '12345678';

    test('should return User when credentials match', () async {
      when(() => mockApiClient.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          data: {
            'data': {'id': '1', 'email': tEmail, 'name': 'Yordy Espinosa'},
            'token': 'plain-token',
          },
        ),
      );
      when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);

      final result = await repository.signInWithEmailAndPassword(tEmail, tPassword);

      expect(result.isSuccess, true);
      final user = result.fold((l) => null, (r) => r);
      expect(user, isA<UserModel>());
      expect(user?.email, tEmail);
      verify(() => mockSharedPreferences.setString('cached_user', any())).called(1);
      verify(() => mockSharedPreferences.setString('auth_token', 'plain-token')).called(1);
    });

    test('should return ValidationFailure when API fails', () async {
      when(() => mockApiClient.post(any(), data: any(named: 'data'))).thenThrow(Exception('network'));

      final result = await repository.signInWithEmailAndPassword('wrong@email.com', 'wrong');

      expect(result.isFailure, true);
      verifyNever(() => mockSharedPreferences.setString(any(), any()));
    });
  });

  group('getCurrentUser', () {
    test('should return User when there is one in cache', () async {
      final tUserModel = UserModel(id: '1', email: 'test@test.com', name: 'Test User');
      when(() => mockSharedPreferences.getString('cached_user'))
          .thenReturn(json.encode(tUserModel.toMap()));

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, true);
      expect(result.fold((l) => null, (r) => r), equals(tUserModel));
    });

    test('should return null when there is no user in cache', () async {
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, true);
      expect(result.fold((l) => null, (r) => r), isNull);
    });
  });
}

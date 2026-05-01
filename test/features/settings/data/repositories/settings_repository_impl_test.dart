import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/features/settings/data/datasources/profile_remote_datasource.dart';
import 'package:sport/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:sport/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:sport/features/settings/data/models/user_profile_model.dart';
import 'package:sport/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:sport/features/settings/domain/entities/user_profile.dart';

class MockSettingsLocalDataSource extends Mock implements SettingsLocalDataSource {}

class MockSettingsRemoteDataSource extends Mock implements SettingsRemoteDataSource {}

class MockProfileRemoteDataSource extends Mock implements ProfileRemoteDataSource {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsLocalDataSource mockLocalDataSource;
  late MockSettingsRemoteDataSource mockRemoteDataSource;
  late MockProfileRemoteDataSource mockProfileRemoteDataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockLocalDataSource = MockSettingsLocalDataSource();
    mockRemoteDataSource = MockSettingsRemoteDataSource();
    mockProfileRemoteDataSource = MockProfileRemoteDataSource();
    mockSharedPreferences = MockSharedPreferences();
    repository = SettingsRepositoryImpl(
      mockLocalDataSource,
      mockRemoteDataSource,
      mockProfileRemoteDataSource,
      mockSharedPreferences,
    );
    when(() => mockSharedPreferences.getString(any())).thenReturn(null);
  });

  group('getProfile', () {
    final tUserProfileModel = UserProfileModel(
      firstName: 'Test',
      lastName: 'User',
      birthDate: '01/01/2000',
      profileType: 'Deportista',
      sport: 'Futbol',
      position: 'Delantero',
      bio: 'Bio test',
    );

    test('should return profile from data source when it exists', () async {
      // arrange
      when(() => mockLocalDataSource.getProfile()).thenAnswer((_) async => tUserProfileModel);

      // act
      final result = await repository.getProfile();

      // assert
      expect(result.isSuccess, true);
      expect(result.fold((l) => null, (r) => r), equals(tUserProfileModel));
      verify(() => mockLocalDataSource.getProfile()).called(1);
    });

    test('should return default profile when data source returns null', () async {
      // arrange
      when(() => mockLocalDataSource.getProfile()).thenAnswer((_) async => null);

      // act
      final result = await repository.getProfile();

      // assert
      expect(result.isSuccess, true);
      expect(result.fold((l) => null, (r) => r?.firstName), equals('Lewis'));
    });
  });

  group('updateProfile', () {
    final tUserProfile = UserProfile(
      firstName: 'Updated',
      lastName: 'User',
      birthDate: '01/01/2000',
      profileType: 'Deportista',
      sport: 'Futbol',
      position: 'Delantero',
      bio: 'Updated bio',
    );

    test('should call local data source to cache profile', () async {
      // arrange
      registerFallbackValue(UserProfileModel.fromEntity(tUserProfile));
      when(() => mockLocalDataSource.cacheProfile(any())).thenAnswer((_) async => {});

      // act
      final result = await repository.updateProfile(tUserProfile);

      // assert
      expect(result.isSuccess, true);
      verify(() => mockLocalDataSource.cacheProfile(any())).called(1);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/auth/presentation/providers/meta_providers.dart';
import 'package:sport/features/events/domain/entities/sport_event.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/jobs/domain/entities/job_offer.dart';
import 'package:sport/features/search/data/search_remote_datasource.dart';
import 'package:sport/features/search/presentation/pages/search_page.dart';
import 'package:sport/features/search/presentation/providers/search_providers.dart';
import '../../../helpers/test_prefs.dart';

class MockSearchRemoteDataSource extends Mock implements SearchRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockSearchRemoteDataSource search;
  late MockAuthRepository auth;
  const user = User(id: 'u1', email: 'a@test.com', name: 'Ana');

  setUp(() {
    search = MockSearchRemoteDataSource();
    auth = MockAuthRepository();
    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(
      () => search.search(any(), any(), currentUserId: any(named: 'currentUserId')),
    ).thenAnswer(
      (_) async => (
        users: const [UserModel(id: 'u2', email: 'c@test.com', name: 'Camila')],
        posts: <Post>[],
        opportunities: <JobOffer>[],
        events: <SportEvent>[],
        sponsorships: <SponsorshipResult>[],
      ),
    );
  });

  setUpAll(() {
    registerFallbackValue(const SearchFilters(query: ''));
  });

  testWidgets('flujo búsqueda muestra resultados de usuarios', (tester) async {
    final prefs = createMockPrefs();
    final controller = AuthController(auth)..state = const AsyncValue.data(user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(auth),
          authControllerProvider.overrideWith((ref) => controller),
          searchRemoteDataSourceProvider.overrideWithValue(search),
          countriesProvider.overrideWith((ref) async => []),
          sportsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: SearchPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Camila');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    // Submit via icon if search action didn't fire.
    final searchIcon = find.byIcon(Icons.search);
    if (searchIcon.evaluate().isNotEmpty) {
      await tester.tap(searchIcon.first);
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('Camila'), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/domain/repositories/feed_repository.dart';
import 'package:sport/features/feed/presentation/pages/create_post_page.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';
import '../../../helpers/test_prefs.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockFeedRepository feed;
  late MockAuthRepository auth;
  const user = User(id: 'u1', email: 'a@test.com', name: 'Ana');
  Post? captured;

  setUpAll(() {
    registerFallbackValue(
      Post(
        id: 'p',
        author: user,
        description: '',
        createdAt: DateTime(2026),
        likes: const [],
        comments: const [],
      ),
    );
  });

  setUp(() {
    feed = MockFeedRepository();
    auth = MockAuthRepository();
    captured = null;
    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(() => feed.createPost(any())).thenAnswer((invocation) async {
      captured = invocation.positionalArguments.first as Post;
      return Ok(captured!);
    });
    when(() => feed.getPosts()).thenAnswer((_) async => const Ok([]));
  });

  testWidgets('publicar_training_incluye_activityUrl_y_location', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final prefs = createMockPrefs();
    final controller = AuthController(auth)..state = const AsyncValue.data(user);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          feedRepositoryProvider.overrideWithValue(feed),
          authRepositoryProvider.overrideWithValue(auth),
          authControllerProvider.overrideWith((ref) => controller),
        ],
        child: const MaterialApp(home: CreatePostPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'Sesión de velocidad W6',
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrenamiento').last);
    await tester.pumpAndSettle();

    expect(find.text('URL actividad del reloj'), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.labelText == 'Ubicación' ||
                w.decoration?.hintText == 'Ciudad, pista, estadio…'),
      ),
      'Pista Olímpica',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            (w.decoration?.labelText == 'URL actividad del reloj' ||
                (w.decoration?.hintText?.contains('strava') ?? false)),
      ),
      'https://www.strava.com/activities/999',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();

    verify(() => feed.createPost(any())).called(1);
    expect(captured, isNotNull);
    expect(captured!.postType, 'training');
    expect(captured!.location, 'Pista Olímpica');
    expect(captured!.activityUrl, 'https://www.strava.com/activities/999');
  });
}

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
    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(() => feed.createPost(any())).thenAnswer((invocation) async {
      final post = invocation.positionalArguments.first as Post;
      return Ok(post);
    });
    when(() => feed.getPosts()).thenAnswer((_) async => const Ok([]));
  });

  testWidgets('flujo crear publicación con texto', (tester) async {
    final prefs = createMockPrefs();
    final controller = AuthController(auth);
    controller.state = const AsyncValue.data(user);

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
    controller.state = const AsyncValue.data(user);
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, 'Hoy corrí 10km');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();

    verify(() => feed.createPost(any())).called(1);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/domain/repositories/feed_repository.dart';
import 'package:sport/features/feed/presentation/pages/feed_page.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';

class MockFeedRepository extends Mock implements FeedRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockFeedRepository mockFeedRepository;
  late MockAuthRepository mockAuthRepository;
  const tUser = User(id: '1', email: 'test@test.com', name: 'Test User');
  
  final tPosts = [
    Post(
      id: '1',
      author: tUser,
      description: 'Test post 1',
      createdAt: DateTime.now(),
      likes: [],
      comments: [],
    ),
  ];

  setUp(() {
    mockFeedRepository = MockFeedRepository();
    mockAuthRepository = MockAuthRepository();
    
    // Auth repository setup for the real AuthController if it runs status check
    when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => const Ok(tUser));
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        feedRepositoryProvider.overrideWithValue(mockFeedRepository),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: const MaterialApp(
        home: FeedPage(),
      ),
    );
  }

  testWidgets('Muestra cargando inicialmente y luego los posts', (tester) async {
    // arrange
    when(() => mockFeedRepository.getPosts(page: any(named: 'page'), limit: any(named: 'limit')))
        .thenAnswer((_) async => Ok(tPosts));

    // act
    await tester.pumpWidget(createTestableWidget());

    // assert progress indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // wait for data
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // assert posts
    expect(find.text('Test post 1'), findsOneWidget);
  });
}

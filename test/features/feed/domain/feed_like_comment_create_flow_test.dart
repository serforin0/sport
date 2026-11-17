import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/domain/repositories/feed_repository.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository feed;
  const user = User(id: 'u1', email: 'a@test.com', name: 'Ana');
  final post = Post(
    id: 'p1',
    author: user,
    description: 'Entreno',
    createdAt: DateTime(2026, 1, 1),
    likes: const [],
    comments: const [],
  );

  setUpAll(() {
    registerFallbackValue(post);
  });

  setUp(() {
    feed = MockFeedRepository();
  });

  test('flujo create → like → comment', () async {
    when(() => feed.createPost(any())).thenAnswer((_) async => Ok(post));
    when(() => feed.likePost('p1', 'u2')).thenAnswer((_) async => const Ok(true));
    when(
      () => feed.addComment('p1', 'u2', 'Vamos!'),
    ).thenAnswer((_) async => Ok(post));
    when(
      () => feed.getPosts(page: any(named: 'page'), limit: any(named: 'limit')),
    ).thenAnswer((_) async => Ok([post]));

    final created = await feed.createPost(post);
    expect(created.isSuccess, isTrue);

    final liked = await feed.likePost('p1', 'u2');
    expect(liked.isSuccess, isTrue);

    final commented = await feed.addComment('p1', 'u2', 'Vamos!');
    expect(commented.isSuccess, isTrue);

    final list = await feed.getPosts();
    expect((list as Ok<List<Post>>).value, hasLength(1));
  });
}

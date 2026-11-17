import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/feed/domain/entities/post.dart';
import 'package:sport/features/feed/domain/repositories/feed_repository.dart';

class MockFeedRepository extends Mock implements FeedRepository {}

void main() {
  late MockFeedRepository feed;

  const author = User(id: 'u1', email: 'a@test.com', name: 'Author');
  final post = Post(
    id: 'p1',
    author: author,
    description: 'Entrenamiento matutino',
    createdAt: DateTime(2026, 1, 1),
    likes: const [],
    comments: const [],
  );

  setUp(() {
    feed = MockFeedRepository();
  });

  test('flujo getPosts → like → comment', () async {
    when(
      () => feed.getPosts(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Ok([post]));
    when(
      () => feed.likePost('p1', 'u2'),
    ).thenAnswer((_) async => const Ok(true));
    when(
      () => feed.addComment('p1', 'u2', 'Gran ritmo'),
    ).thenAnswer((_) async => Ok(post));

    final list = await feed.getPosts(page: 1, limit: 20);
    expect(list.isSuccess, isTrue);
    expect((list as Ok<List<Post>>).value.single.id, 'p1');

    final liked = await feed.likePost('p1', 'u2');
    expect(liked.isSuccess, isTrue);

    final commented = await feed.addComment('p1', 'u2', 'Gran ritmo');
    expect(commented.isSuccess, isTrue);
  });
}

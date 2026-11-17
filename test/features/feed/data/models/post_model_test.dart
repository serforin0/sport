import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/feed/data/models/post_model.dart';

void main() {
  test('fromApi usa nombres de likes y no el ULID como texto', () {
    final post = PostModel.fromApi({
      'id': 'post-1',
      'body': 'Entrenamiento',
      'user': {'id': 'u1', 'email': 'a@test.com', 'name': 'Autor'},
      'likes': [
        {'id': 'fan-1', 'name': 'Diego Vargas'},
      ],
    }, currentUserId: 'u1');

    expect(post.likes, ['fan-1']);
    expect(post.likeNames, ['Diego Vargas']);
    expect(post.likeSummary, 'Le ha gustado a Diego Vargas');
  });
}

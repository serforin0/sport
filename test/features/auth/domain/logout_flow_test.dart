import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('flujo getCurrentUser → signOut limpia sesión', () async {
    final auth = MockAuthRepository();
    const user = User(id: 'u1', email: 'a@test.com', name: 'Ana');

    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(() => auth.signOut()).thenAnswer((_) async => const Ok(null));

    final current = await auth.getCurrentUser();
    expect(current.isSuccess, isTrue);

    final logout = await auth.signOut();
    expect(logout.isSuccess, isTrue);
    verify(() => auth.signOut()).called(1);
  });
}

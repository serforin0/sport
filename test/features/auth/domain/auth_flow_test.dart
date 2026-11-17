import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository auth;

  const user = User(
    id: 'u1',
    email: 'ana@hubsport.test',
    name: 'Ana Pérez',
  );

  setUp(() {
    auth = MockAuthRepository();
  });

  test('flujo login → usuario actual → logout', () async {
    when(
      () => auth.signInWithEmailAndPassword('ana@hubsport.test', 'Password1!'),
    ).thenAnswer((_) async => const Ok(user));
    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(user));
    when(() => auth.signOut()).thenAnswer((_) async => const Ok(null));

    final login = await auth.signInWithEmailAndPassword(
      'ana@hubsport.test',
      'Password1!',
    );
    expect(login.isSuccess, isTrue);
    expect((login as Ok<User>).value.email, 'ana@hubsport.test');

    final current = await auth.getCurrentUser();
    expect(current.isSuccess, isTrue);
    expect((current as Ok<User?>).value?.id, 'u1');

    final logout = await auth.signOut();
    expect(logout.isSuccess, isTrue);

    verifyInOrder([
      () => auth.signInWithEmailAndPassword('ana@hubsport.test', 'Password1!'),
      () => auth.getCurrentUser(),
      () => auth.signOut(),
    ]);
  });

  test('flujo registro completa perfil requerido', () async {
    when(
      () => auth.signUpWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
        countryId: any(named: 'countryId'),
        city: any(named: 'city'),
        sportId: any(named: 'sportId'),
        profileType: any(named: 'profileType'),
      ),
    ).thenAnswer((_) async => const Ok(user));

    final result = await auth.signUpWithEmailAndPassword(
      email: 'ana@hubsport.test',
      password: 'Password1!',
      name: 'Ana Pérez',
      countryId: 'do',
      city: 'Santo Domingo',
      sportId: 'football',
      profileType: 'athlete',
    );

    expect(result.isSuccess, isTrue);
    verify(
      () => auth.signUpWithEmailAndPassword(
        email: 'ana@hubsport.test',
        password: 'Password1!',
        name: 'Ana Pérez',
        countryId: 'do',
        city: 'Santo Domingo',
        sportId: 'football',
        profileType: 'athlete',
      ),
    ).called(1);
  });
}

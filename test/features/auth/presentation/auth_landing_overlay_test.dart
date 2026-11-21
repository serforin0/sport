import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/domain/repositories/auth_repository.dart';
import 'package:sport/features/auth/presentation/pages/auth_landing_page.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('auth_landing_muestra_gradiente_inferior_sobre_fondo', (
    tester,
  ) async {
    final auth = MockAuthRepository();
    when(() => auth.getCurrentUser()).thenAnswer((_) async => const Ok(null));
    final controller = AuthController(auth)..state = const AsyncValue.data(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          authControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          home: AuthPage(
            background: const ColoredBox(color: Colors.blue),
            enableDemoLogin: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final decorated = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
    final hasGradient = decorated.any((box) {
      final deco = box.decoration;
      return deco is BoxDecoration && deco.gradient is LinearGradient;
    });
    expect(hasGradient, isTrue);
    expect(find.textContaining('ENTRAR'), findsWidgets);
  });
}

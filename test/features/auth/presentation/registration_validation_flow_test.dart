import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';
import 'package:sport/features/auth/presentation/pages/registration_page.dart';
import 'package:sport/features/auth/presentation/providers/meta_providers.dart';

void main() {
  testWidgets('registro no avanza con paso 0 vacío', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          countriesProvider.overrideWith(
            (ref) async => [
              Country(id: 'do', name: 'República Dominicana', code: 'DO'),
            ],
          ),
          sportsProvider.overrideWith(
            (ref) async => [Sport(id: 's1', name: 'Fútbol')],
          ),
        ],
        child: const MaterialApp(home: RegistrationPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    expect(
      find.text('Completa todos los campos requeridos'),
      findsOneWidget,
    );
  });
}

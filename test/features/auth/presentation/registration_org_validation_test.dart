import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/auth/domain/entities/meta.dart';
import 'package:sport/features/auth/presentation/pages/registration_page.dart';
import 'package:sport/features/auth/presentation/providers/meta_providers.dart';

void main() {
  Future<void> pumpRegistration(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
  }

  Future<void> completeStep0(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'Rec');
    await tester.enterText(find.byType(TextField).at(1), 'Ruiter');
    await tester.enterText(find.byType(TextField).at(2), 'rec@test.com');
    await tester.enterText(find.byType(TextField).at(3), 'Password1!');
    await tester.enterText(find.byType(TextField).at(4), 'Password1!');
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
  }

  testWidgets('sponsor_campos_org_visibles', (tester) async {
    await pumpRegistration(tester);
    await completeStep0(tester);

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marca / Patrocinador').last);
    await tester.pumpAndSettle();

    expect(find.text('Organización *'), findsOneWidget);
    expect(find.text('RNC *'), findsOneWidget);
    expect(find.text('URL documento de respaldo *'), findsOneWidget);
    expect(find.textContaining('quedará en revisión'), findsOneWidget);
  });

  testWidgets('reclutador_sin_rnc_muestra_snack_completa_organizacion', (
    tester,
  ) async {
    await pumpRegistration(tester);
    await completeStep0(tester);

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reclutador').last);
    await tester.pumpAndSettle();

    // País
    await tester.tap(find.byType(DropdownButton<Country>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('República Dominicana').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Ej. Santo Domingo',
      ),
      'Santo Domingo',
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'AAAA-MM-DD',
      ),
      '1988-01-01',
    );
    // Leave org/RNC empty
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();

    expect(
      find.text('Completa organización, RNC y documento'),
      findsOneWidget,
    );
  });
}

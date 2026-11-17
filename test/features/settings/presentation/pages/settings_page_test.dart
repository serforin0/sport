import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/settings_page.dart';
import '../../../../helpers/settings_test_harness.dart';

void main() {
  testWidgets('Muestra la información del perfil correctamente', (tester) async {
    await tester.pumpWidget(wrapSettings(const SettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Lewis Hamilton'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
  });

  testWidgets('Navega a editar perfil al tocar el tile', (tester) async {
    await tester.pumpWidget(wrapSettings(const SettingsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();

    expect(find.text('EDITAR PERFIL'), findsOneWidget);
  });
}

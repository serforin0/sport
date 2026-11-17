import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/privacy_settings_page.dart';
import '../../../../helpers/settings_test_harness.dart';

void main() {
  testWidgets('PrivacySettingsPage renders all elements', (tester) async {
    await tester.pumpWidget(wrapSettings(const PrivacySettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('PRIVACIDAD'), findsOneWidget);
    expect(find.text('Perfil público'), findsOneWidget);
    expect(find.text('Mostrar estadísticas'), findsOneWidget);
    expect(find.text('Usuarios bloqueados'), findsOneWidget);
  });

  testWidgets('PrivacySettingsPage navigation to blocked users', (tester) async {
    await tester.pumpWidget(wrapSettings(const PrivacySettingsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Usuarios bloqueados'));
    await tester.pumpAndSettle();
  });
}

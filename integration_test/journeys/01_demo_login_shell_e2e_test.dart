import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/onboarding/presentation/pages/role_guide_page.dart';
import 'package:sport/features/shell/main_shell.dart';

import '../support/e2e_harness.dart';

/// Journey 1: landing demo → (guía rol) → MainShell
void main() {
  e2eBinding();

  testWidgets('e2e_demo_login_llega_a_shell', (tester) async {
    final prefs = await e2eInitPrefs(roleGuideDone: false);
    await e2ePumpApp(tester, prefs: prefs);

    await e2eTapDemoLogin(tester);
    // Tras login demo suele aparecer RoleGuide la primera vez
    if (find.byType(RoleGuidePage).evaluate().isNotEmpty) {
      expect(find.text('Empezar'), findsOneWidget);
      await e2eCompleteRoleGuideIfPresent(tester);
    }

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Inicio'), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 2)));
}

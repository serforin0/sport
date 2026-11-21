import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/safety/presentation/pages/reports_inbox_page.dart';
import 'package:sport/features/settings/presentation/pages/help_support_page.dart';
import 'package:sport/features/shell/main_shell.dart';

import '../support/e2e_harness.dart';

/// Journey 5: drawer → Ayuda → Bandeja de reportes
void main() {
  e2eBinding();

  testWidgets('e2e_ayuda_abre_bandeja_reportes', (tester) async {
    final prefs = await e2eInitPrefs(roleGuideDone: true);
    await e2ePumpApp(tester, prefs: prefs);

    await e2eTapDemoLogin(tester);
    await e2eCompleteRoleGuideIfPresent(tester);
    expect(find.byType(MainShell), findsOneWidget);

    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Drawer → Configuración → Ayuda y soporte
    final config = find.text('Configuración');
    expect(config, findsOneWidget);
    await tester.ensureVisible(config);
    await tester.tap(config);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final help = find.textContaining('Ayuda');
    expect(help, findsWidgets);
    await tester.ensureVisible(help.first);
    await tester.tap(help.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(
      find.byType(HelpSupportPage).evaluate().isNotEmpty ||
          find.text('Bandeja de reportes').evaluate().isNotEmpty,
      isTrue,
    );

    final bandeja = find.text('Bandeja de reportes');
    await tester.ensureVisible(bandeja);
    await tester.tap(bandeja);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(ReportsInboxPage), findsOneWidget);
    // Demo user no es moderador: puede ver error o lista
    expect(
      find.text('Reportes').evaluate().isNotEmpty ||
          find.textContaining('No autorizado').evaluate().isNotEmpty ||
          find.text('No hay reportes abiertos').evaluate().isNotEmpty,
      isTrue,
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}

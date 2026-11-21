import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/profile/presentation/pages/profile_page.dart';
import 'package:sport/features/scout_metrics/presentation/pages/scout_metrics_page.dart';
import 'package:sport/features/shell/main_shell.dart';

import '../support/e2e_harness.dart';

/// Journey 4: drawer → perfil → Perfil scout → agregar video (UI)
void main() {
  e2eBinding();

  testWidgets('e2e_perfil_scout_videos_ui', (tester) async {
    final prefs = await e2eInitPrefs(roleGuideDone: true);
    await e2ePumpApp(tester, prefs: prefs);

    await e2eTapDemoLogin(tester);
    await e2eCompleteRoleGuideIfPresent(tester);
    expect(find.byType(MainShell), findsOneWidget);

    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final verPerfil = find.text('Ver mi perfil');
    expect(verPerfil, findsOneWidget);
    await tester.tap(verPerfil);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(ProfilePage), findsOneWidget);

    final scoutLink = find.textContaining('Perfil scout');
    await tester.scrollUntilVisible(
      scoutLink.first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(scoutLink.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(
      find.byType(ScoutMetricsPage).evaluate().isNotEmpty ||
          find.text('Perfil scout').evaluate().isNotEmpty ||
          find.text('Videos').evaluate().isNotEmpty,
      isTrue,
      reason: 'Debe abrirse Perfil scout o mostrar sección Videos',
    );

    if (find.text('Videos').evaluate().isNotEmpty ||
        find.text('Agregar video').evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        find.text('Agregar video'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Agregar video'), findsOneWidget);
      expect(find.text('Guardar perfil scout'), findsOneWidget);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}

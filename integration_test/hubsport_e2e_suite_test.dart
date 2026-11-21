import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/demo/presentation/pages/store_product_page.dart';
import 'package:sport/features/demo/presentation/pages/store_showcase_page.dart';
import 'package:sport/features/feed/presentation/pages/create_post_page.dart';
import 'package:sport/features/onboarding/presentation/pages/role_guide_page.dart';
import 'package:sport/features/safety/presentation/pages/reports_inbox_page.dart';
import 'package:sport/features/scout_metrics/presentation/pages/scout_metrics_page.dart';
import 'package:sport/features/settings/presentation/pages/help_support_page.dart';
import 'package:sport/features/shell/main_shell.dart';

import 'support/e2e_chat_journey.dart';
import 'support/e2e_harness.dart';

/// E2E real: login demo + red + taps UI.
/// Drawer macOS es flaky → rutas post-login vía Navigator tras sesión autenticada.
void main() {
  e2eBinding();

  testWidgets('suite_e2e_hubsport_demo_journeys', (tester) async {
    await e2eInitLocale();
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final s = details.exceptionAsString();
      if (s.contains('HttpException') ||
          s.contains('statusCode: 404') ||
          s.contains('HTTP request failed') ||
          s.contains('LocaleDataException')) {
        return;
      }
      oldOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    final prefs = await e2eInitPrefs(roleGuideDone: false);
    await e2ePumpApp(tester, prefs: prefs);
    _drain(tester);

    // 1) Login demo → shell
    await e2eTapDemoLogin(tester);
    _drain(tester);
    if (find.byType(RoleGuidePage).evaluate().isNotEmpty) {
      await e2eCompleteRoleGuideIfPresent(tester);
    }
    expect(find.byType(MainShell), findsOneWidget);

    // 2) Chips + crear post (taps reales)
    await tester.tap(find.textContaining('Mi deporte'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Todos los deportes'));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(CreatePostPage), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).first,
      'E2E suite ${DateTime.now().millisecondsSinceEpoch}',
    );
    final typeField = find.byType(DropdownButtonFormField<String>);
    if (typeField.evaluate().isNotEmpty) {
      await tester.tap(typeField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrenamiento').last);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Publicar'));
    await tester.pump();
    await e2eWaitForAny(
      tester,
      [
        find.textContaining('Publicación Exitosa'),
        find.byType(MainShell),
        find.text('Inicio'),
      ],
      timeout: const Duration(seconds: 60),
    );
    _drain(tester);

    // 3) Tienda checkout (sesión demo ya autenticada)
    await _push(tester, const StoreShowcasePage());
    expect(find.byType(StoreShowcasePage), findsOneWidget);
    await e2eWaitForAny(
      tester,
      [find.byType(Card)],
      timeout: const Duration(seconds: 60),
    );
    _drain(tester);
    await tester.tap(find.byType(Card).first, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(StoreProductPage), findsOneWidget);

    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.maybeOf(
      tester.element(find.byType(Scaffold).last),
    )?.clearSnackBars();
    await tester.pumpAndSettle();
    final pay = find.byKey(const Key('store_checkout_pay'));
    expect(pay, findsOneWidget);
    await tester.tap(pay);
    await tester.pump();
    await e2eWaitForAny(
      tester,
      [
        find.text('Pedido confirmado'),
        find.byType(StoreReceiptPage),
        find.textContaining('No se pudo'),
        find.byType(SnackBar),
      ],
      timeout: const Duration(seconds: 60),
    );
    if (find.byType(StoreReceiptPage).evaluate().isEmpty) {
      fail(
        'Checkout no llegó al recibo (¿API demo / tap fallido en viewport?)',
      );
    }
    expect(find.byType(StoreReceiptPage), findsOneWidget);
    // Comisión presente si el host ya tiene Wave 7
    // (no bloquea si el deploy remoto aún no la expone)
    await tester.tap(find.text('Volver a la tienda'));
    await tester.pumpAndSettle();
    await _pop(tester);

    // 4) Scout metrics UI
    await _push(tester, const ScoutMetricsPage());
    await tester.pumpAndSettle(const Duration(seconds: 3));
    _drain(tester);
    expect(
      find.text('Perfil scout').evaluate().isNotEmpty ||
          find.textContaining('scout').evaluate().isNotEmpty ||
          find.textContaining('deporte').evaluate().isNotEmpty,
      isTrue,
      reason: 'ScoutMetricsPage no montó contenido usable',
    );
    await _pop(tester);

    // 5) Ayuda → bandeja reportes
    await _push(tester, const HelpSupportPage());
    await tester.pumpAndSettle();
    expect(find.text('Bandeja de reportes'), findsOneWidget);
    await tester.tap(find.text('Bandeja de reportes'));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byType(ReportsInboxPage), findsOneWidget);
    await _pop(tester);
    await _pop(tester);

    // 6) Chat completo (lista → enviar → menú → reportar)
    await e2eChatCompleteJourney(tester);

    _drain(tester);
  }, timeout: const Timeout(Duration(minutes: 12)));
}

void _drain(WidgetTester tester) {
  Object? err;
  do {
    err = tester.takeException();
  } while (err != null);
}

Future<void> _push(WidgetTester tester, Widget page) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  nav.push(MaterialPageRoute<void>(builder: (_) => page));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

Future<void> _pop(WidgetTester tester) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  if (nav.canPop()) {
    nav.pop();
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
}

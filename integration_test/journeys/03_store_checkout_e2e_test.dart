import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/demo/presentation/pages/store_product_page.dart';
import 'package:sport/features/demo/presentation/pages/store_showcase_page.dart';
import 'package:sport/features/shell/main_shell.dart';

import '../support/e2e_harness.dart';

/// Journey 3: drawer → Tienda → producto → pagar → recibo con comisión 12%
void main() {
  e2eBinding();

  testWidgets('e2e_tienda_checkout_comision_12', (tester) async {
    final prefs = await e2eInitPrefs(roleGuideDone: true);
    await e2ePumpApp(tester, prefs: prefs);

    await e2eTapDemoLogin(tester);
    await e2eCompleteRoleGuideIfPresent(tester);
    expect(find.byType(MainShell), findsOneWidget);

    // Abrir end drawer (avatar)
    final avatar = find.byType(CircleAvatar).first;
    await tester.tap(avatar);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final tienda = find.text('Tienda');
    await e2eWaitForAny(tester, [tienda], timeout: const Duration(seconds: 15));
    await tester.ensureVisible(tienda);
    await tester.tap(tienda);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(StoreShowcasePage), findsOneWidget);

    // Primer producto clicable
    await e2eWaitForAny(
      tester,
      [find.byType(Card), find.textContaining('USD')],
      timeout: const Duration(seconds: 45),
    );

    final productCard = find.byType(Card).first;
    await tester.tap(productCard);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(StoreProductPage), findsOneWidget);

    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.maybeOf(
      tester.element(find.byType(Scaffold).last),
    )?.clearSnackBars();
    await tester.pumpAndSettle();
    final pay = find.byKey(const Key('store_checkout_pay'));
    await tester.tap(pay);
    await tester.pump();

    await e2eWaitForAny(
      tester,
      [
        find.text('Pedido confirmado'),
        find.byType(StoreReceiptPage),
        find.textContaining('Comisión HubSport'),
      ],
      timeout: const Duration(seconds: 45),
    );

    expect(find.textContaining('Comisión HubSport'), findsOneWidget);
    expect(find.textContaining('12'), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 3)));
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/notification_settings_page.dart';
import '../../../../helpers/settings_test_harness.dart';

void main() {
  testWidgets('NotificationSettingsPage renders all switches', (tester) async {
    await tester.pumpWidget(wrapSettings(const NotificationSettingsPage()));
    await tester.pumpAndSettle();

    expect(find.text('NOTIFICACIONES'), findsOneWidget);
    expect(find.text('Notificaciones Push'), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('NotificationSettingsPage toggles work', (tester) async {
    await tester.pumpWidget(wrapSettings(const NotificationSettingsPage()));
    await tester.pumpAndSettle();

    final pushSwitch = find.byType(Switch).first;
    expect(tester.widget<Switch>(pushSwitch).value, isTrue);

    await tester.tap(pushSwitch);
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(pushSwitch).value, isFalse);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/notification_settings_page.dart';

void main() {
  testWidgets('NotificationSettingsPage renders all switches', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationSettingsPage()));

    expect(find.text('NOTIFICACIONES'), findsOneWidget);
    expect(find.text('CANALES PRINCIPALES'), findsOneWidget);
    expect(find.text('ACTIVIDAD'), findsOneWidget);

    // Verify specifically for switches
    expect(find.text('Notificaciones Push'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Mensajes directos'), findsOneWidget);
    expect(find.text('Nuevos eventos'), findsOneWidget);
    expect(find.text('Consejos de entrenamiento'), findsOneWidget);

    expect(find.byType(Switch), findsNWidgets(5));
  });

  testWidgets('NotificationSettingsPage toggles work', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationSettingsPage()));

    final pushSwitch = find.byType(Switch).first;
    
    // Initial state should be true as per implementation
    expect(tester.widget<Switch>(pushSwitch).value, isTrue);

    await tester.tap(pushSwitch);
    await tester.pump();

    // After tap, it should be false
    expect(tester.widget<Switch>(pushSwitch).value, isFalse);
  });
}

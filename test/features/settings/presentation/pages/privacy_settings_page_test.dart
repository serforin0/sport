import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/privacy_settings_page.dart';

void main() {
  testWidgets('PrivacySettingsPage renders all elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacySettingsPage()));

    expect(find.text('PRIVACIDAD'), findsOneWidget);
    expect(find.text('VISIBILIDAD'), findsOneWidget);
    expect(find.text('INTERACCIONES'), findsOneWidget);

    expect(find.text('Perfil público'), findsOneWidget);
    expect(find.text('Mostrar estadísticas'), findsOneWidget);
    expect(find.text('Mensajes de desconocidos'), findsOneWidget);
    expect(find.text('Usuarios bloqueados'), findsOneWidget);
    expect(find.text('Eliminar mi cuenta'), findsOneWidget);

    expect(find.byType(Switch), findsNWidgets(3));
  });

  testWidgets('PrivacySettingsPage navigation to blocked users', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacySettingsPage()));

    final blockedTile = find.text('Usuarios bloqueados');
    expect(blockedTile, findsOneWidget);
    
    // We can't easily test navigation unless we mock the navigator, 
    // but we can verify it's tappable.
    await tester.tap(blockedTile);
    await tester.pumpAndSettle();
  });
}

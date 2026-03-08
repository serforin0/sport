import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/help_support_page.dart';

void main() {
  testWidgets('HelpSupportPage renders all elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpSupportPage()));

    expect(find.text('AYUDA Y SOPORTE'), findsOneWidget);
    expect(find.text('¿Cómo podemos ayudarte?'), findsOneWidget);
    
    expect(find.text('Centro de Ayuda / FAQ'), findsOneWidget);
    expect(find.text('Contactar Soporte'), findsOneWidget);
    expect(find.text('Reportar un problema'), findsOneWidget);
    expect(find.text('Términos y condiciones'), findsOneWidget);
    
    expect(find.text('CALIFICAR AHORA'), findsOneWidget);
  });
}

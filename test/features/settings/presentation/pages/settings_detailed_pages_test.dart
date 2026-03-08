import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/security_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/billing_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/social_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/general_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/contact_support_page.dart';

void main() {
  group('Settings Detailed Pages Tests', () {
    
    testWidgets('ContactSupportPage validation errors', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(const MaterialApp(home: ContactSupportPage()));
      
      final sendButton = find.text('Enviar');
      await tester.ensureVisible(sendButton);
      await tester.tap(sendButton);
      await tester.pump();
      
      expect(find.text('El mensaje no puede estar vacío'), findsOneWidget);
      
      // Use find.byType(TextFormField) directly or by descendant of Form
      final textField = find.byType(TextFormField);
      await tester.enterText(textField, 'Short');
      await tester.tap(sendButton);
      await tester.pump();
      
      expect(find.text('El mensaje debe ser más detallado (mín. 10 caracteres)'), findsOneWidget);
    });
    
    testWidgets('SecuritySettingsPage rendering', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SecuritySettingsPage()));
      expect(find.text('SEGURIDAD'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
    });

    testWidgets('BillingSettingsPage rendering', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: BillingSettingsPage()));
      expect(find.text('FACTURACIÓN'), findsOneWidget);
      expect(find.text('MEJORAR PLAN'), findsOneWidget);
    });

    testWidgets('SocialSettingsPage rendering', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SocialSettingsPage()));
      expect(find.text('SOCIAL'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
    });

    testWidgets('GeneralSettingsPage rendering', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GeneralSettingsPage()));
      expect(find.text('GENERAL'), findsOneWidget);
    });

    testWidgets('ContactSupportPage dropdown selection', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ContactSupportPage()));
      
      expect(find.text('Problema/error en la app'), findsOneWidget);
      
      await tester.tap(find.text('Problema/error en la app'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Sugerencia y mejoras').last);
      await tester.pumpAndSettle();
      
      expect(find.text('Sugerencia y mejoras'), findsOneWidget);
    });
  });
}

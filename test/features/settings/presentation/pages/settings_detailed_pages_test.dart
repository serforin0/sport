import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/security_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/billing_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/social_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/general_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/contact_support_page.dart';

void main() {
  group('Settings Detailed Pages Tests', () {
    testWidgets('SecuritySettingsPage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SecuritySettingsPage()));
      expect(find.text('SEGURIDAD'), findsOneWidget);
      expect(find.text('ACCESO'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
      expect(find.text('Tu cuenta está protegida'), findsOneWidget);
    });

    testWidgets('BillingSettingsPage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: BillingSettingsPage()));
      expect(find.text('FACTURACIÓN'), findsOneWidget);
      expect(find.text('SUSCRIPCIÓN'), findsOneWidget);
      expect(find.text('HubSport Premium'), findsOneWidget);
      expect(find.text('MEJORAR PLAN'), findsOneWidget);
    });

    testWidgets('SocialSettingsPage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SocialSettingsPage()));
      expect(find.text('SOCIAL'), findsOneWidget);
      expect(find.text('GESTIÓN DE USUARIOS'), findsOneWidget);
      expect(find.text('Usuarios bloqueados'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
    });

    testWidgets('GeneralSettingsPage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GeneralSettingsPage()));
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('PREFERENCIAS'), findsOneWidget);
      expect(find.text('Idioma de la aplicación'), findsOneWidget);
    });

    testWidgets('ContactSupportPage renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ContactSupportPage()));
      expect(find.text('CONTACTA CON HUBSPORT'), findsOneWidget);
      expect(find.text('Motivo de contacto'), findsOneWidget);
      expect(find.text('Enviar'), findsOneWidget);
    });
  });
}

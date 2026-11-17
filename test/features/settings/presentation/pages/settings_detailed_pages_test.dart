import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/billing_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/contact_support_page.dart';
import 'package:sport/features/settings/presentation/pages/general_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/security_settings_page.dart';
import 'package:sport/features/settings/presentation/pages/social_settings_page.dart';
import '../../../../helpers/settings_test_harness.dart';

void main() {
  group('Settings Detailed Pages Tests', () {
    testWidgets('ContactSupportPage validation errors', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(wrapSettings(const ContactSupportPage()));
      await tester.pumpAndSettle();

      final sendButton = find.text('Enviar');
      await tester.ensureVisible(sendButton);
      await tester.tap(sendButton);
      await tester.pump();

      expect(find.text('El mensaje no puede estar vacío'), findsOneWidget);
    });

    testWidgets('SecuritySettingsPage rendering', (tester) async {
      await tester.pumpWidget(wrapSettings(const SecuritySettingsPage()));
      await tester.pumpAndSettle();
      expect(find.text('SEGURIDAD'), findsOneWidget);
      expect(find.text('Cambiar contraseña'), findsOneWidget);
    });

    testWidgets('BillingSettingsPage rendering', (tester) async {
      await tester.pumpWidget(wrapSettings(const BillingSettingsPage()));
      await tester.pumpAndSettle();
      expect(find.text('FACTURACIÓN'), findsOneWidget);
    });

    testWidgets('SocialSettingsPage rendering', (tester) async {
      await tester.pumpWidget(wrapSettings(const SocialSettingsPage()));
      await tester.pumpAndSettle();
      expect(find.text('SOCIAL'), findsOneWidget);
    });

    testWidgets('GeneralSettingsPage rendering', (tester) async {
      await tester.pumpWidget(wrapSettings(const GeneralSettingsPage()));
      await tester.pumpAndSettle();
      expect(find.text('GENERAL'), findsOneWidget);
    });

    testWidgets('ContactSupportPage dropdown selection', (tester) async {
      await tester.pumpWidget(wrapSettings(const ContactSupportPage()));
      await tester.pumpAndSettle();

      expect(find.text('Problema/error en la app'), findsOneWidget);
      await tester.tap(find.text('Problema/error en la app'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sugerencia y mejoras').last);
      await tester.pumpAndSettle();
      expect(find.text('Sugerencia y mejoras'), findsOneWidget);
    });
  });
}

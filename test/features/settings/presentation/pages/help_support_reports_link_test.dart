import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/safety/presentation/pages/reports_inbox_page.dart';
import 'package:sport/features/settings/presentation/pages/help_support_page.dart';

void main() {
  testWidgets('muestra_tile_bandeja_de_reportes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: HelpSupportPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bandeja de reportes'), findsOneWidget);
    expect(find.text('Solo moderadores autorizados'), findsOneWidget);
    expect(find.text('Política de privacidad'), findsOneWidget);
  });

  testWidgets('tap_bandeja_reportes_abre_ReportsInboxPage', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportsInboxProvider.overrideWith(
            (ref) async => [
              {
                'reason': 'fake_profile',
                'priority': 'normal',
                'status': 'open',
              },
            ],
          ),
        ],
        child: const MaterialApp(home: HelpSupportPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Bandeja de reportes'));
    await tester.tap(find.text('Bandeja de reportes'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportsInboxPage), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('fake_profile'), findsOneWidget);
  });
}

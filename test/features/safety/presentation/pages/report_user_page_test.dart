import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/safety/data/reports_repository.dart';
import 'package:sport/features/safety/presentation/pages/report_user_page.dart';
import 'package:sport/features/safety/presentation/providers/reports_providers.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  testWidgets('ReportUserPage muestra motivos y envía', (tester) async {
    final repo = MockReportsRepository();
    when(
      () => repo.submit(
        targetUserId: any(named: 'targetUserId'),
        conversationId: any(named: 'conversationId'),
        reason: any(named: 'reason'),
        details: any(named: 'details'),
      ),
    ).thenAnswer((_) async => const Ok('Reporte enviado'));

    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: ReportUserPage(targetUserId: 'u1', targetName: 'Luis'),
        ),
      ),
    );

    expect(find.textContaining('Reportar a Luis'), findsOneWidget);
    expect(find.text('Contacto inapropiado con un menor'), findsOneWidget);

    await tester.tap(find.text('Perfil falso'));
    await tester.pump();
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();

    verify(
      () => repo.submit(
        targetUserId: 'u1',
        conversationId: null,
        reason: 'fake_profile',
        details: any(named: 'details'),
      ),
    ).called(1);
  });
}

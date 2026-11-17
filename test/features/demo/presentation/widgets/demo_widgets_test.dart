import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';
import 'package:sport/features/demo/presentation/widgets/demo_error_view.dart';

void main() {
  testWidgets('DemoBadge muestra etiqueta', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DemoBadge())),
    );
    expect(find.text('Vista de demostración'), findsOneWidget);
  });

  testWidgets('showDemoSimulation abre diálogo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDemoSimulation(context, 'Solo demo'),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Simulación informativa'), findsOneWidget);
    expect(find.text('Solo demo'), findsOneWidget);
    await tester.tap(find.text('Entendido'));
    await tester.pumpAndSettle();
  });

  testWidgets('DemoErrorView reintenta', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DemoErrorView(
            message: 'Falló la carga',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );
    expect(find.text('Falló la carga'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    expect(retried, isTrue);
  });
}

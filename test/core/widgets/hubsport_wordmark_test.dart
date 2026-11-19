import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/core/widgets/hubsport_wordmark.dart';

void main() {
  testWidgets('HubSportWordmark muestra HUBSPORT en RichText', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HubSportWordmark())),
    );

    expect(find.byType(HubSportWordmark), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText() == 'HUBSPORT',
      ),
      findsOneWidget,
    );
  });
}

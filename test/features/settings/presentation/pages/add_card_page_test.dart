import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/add_card_page.dart';

void main() {
  testWidgets('AddCardPage no pide PAN ni CVV', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AddCardPage()));

    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('No introduzcas datos de tarjeta'), findsOneWidget);
    expect(find.textContaining('PAN'), findsOneWidget);
  });
}

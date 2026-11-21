import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/legal/presentation/pages/legal_document_page.dart';

void main() {
  testWidgets('muestra borrador de términos', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LegalDocumentPage(type: LegalDocumentType.terms),
      ),
    );

    expect(find.textContaining('BORRADOR'), findsWidgets);
    expect(find.textContaining('Términos'), findsOneWidget);
  });

  testWidgets('muestra borrador de privacidad', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LegalDocumentPage(type: LegalDocumentType.privacy),
      ),
    );

    expect(find.textContaining('Menores y tutor'), findsOneWidget);
  });
}

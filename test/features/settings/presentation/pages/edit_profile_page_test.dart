import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/settings/presentation/pages/edit_profile_page.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  testWidgets('EditProfilePage renders all fields and buttons', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));

    // Verify title
    expect(find.text('EDITAR PERFIL'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);

    // Verify fields by labels
    expect(find.text('Nombres'), findsOneWidget);
    expect(find.text('Apellidos'), findsOneWidget);
  });

  testWidgets('EditProfilePage validation and text entry', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));

    // Find first name field by its label ancestor
    final firstNameTextField = find.descendant(
      of: find.byKey(const Key('first_name_field')),
      matching: find.byType(TextFormField),
    );
    
    // Test text entry
    await tester.enterText(firstNameTextField, 'Updated Name');
    await tester.pump();
    expect(find.text('Updated Name'), findsOneWidget);
    
    final saveButton = find.text('Guardar');
    await tester.ensureVisible(saveButton);

    // Test validation: Empty
    await tester.enterText(firstNameTextField, '');
    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('Este campo no puede estar vacío'), findsOneWidget);
    
    // Test validation: Short
    await tester.enterText(firstNameTextField, 'A');
    await tester.tap(saveButton);
    await tester.pump();
    expect(find.text('Debe tener al menos 2 caracteres'), findsOneWidget);
  });
}

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
    await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));

    // Verify title
    expect(find.text('EDITAR PERFIL'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget); // New elevated button text

    // Verify fields by labels
    expect(find.text('Nombres'), findsOneWidget);
    expect(find.text('Apellidos'), findsOneWidget);
    expect(find.text('Fecha de nacimiento'), findsOneWidget);
    expect(find.text('Tipo de perfil'), findsOneWidget);
    expect(find.text('Deporte'), findsOneWidget);
    expect(find.text('Posición'), findsOneWidget);
    expect(find.text('BIOGRAFÍA'), findsOneWidget);
    expect(find.text('UBICACIÓN'), findsOneWidget);

    // Verify initial values in TextFields
    expect(find.text('Lewis'), findsOneWidget);
    expect(find.text('Hamilton'), findsOneWidget);
    expect(find.text('07/01/1985'), findsOneWidget);
    expect(find.text('Deportista'), findsOneWidget);
    expect(find.text('Automovilismo'), findsOneWidget);
    expect(find.text('Piloto'), findsOneWidget);

    // Verify icons
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
  });

  testWidgets('EditProfilePage allows entering text', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EditProfilePage()));

    final firstNameField = find.byKey(const Key('first_name_field'));
    expect(firstNameField, findsOneWidget);

    final textField = find.descendant(of: firstNameField, matching: find.byType(TextField));
    await tester.enterText(textField, 'Updated First Name');
    await tester.pump();

    expect(find.text('Updated First Name'), findsOneWidget);
  });
}

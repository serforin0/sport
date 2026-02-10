import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/auth/presentation/pages/auth_landing_page.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: MediaQuery(
      // ✅ en tests a veces el alto queda pequeño, le damos un size estable
      data: const MediaQueryData(size: Size(390, 844)),
      child: child,
    ),
  );
}

void main() {
  testWidgets('Muestra landing inicialmente', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AuthPage(
          background: ColoredBox(color: Colors.black), // ✅ evita video
        ),
      ),
    );

    expect(find.text('Registrarme con correo'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsNothing);
  });

  testWidgets('Cambia a login al tocar Inicia sesión ahora', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AuthPage(
          background: ColoredBox(color: Colors.black), // ✅ evita video
        ),
      ),
    );

    await tester.tap(find.text('Inicia sesión ahora'));
    await tester.pumpAndSettle();

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
  });

  testWidgets('Botón Iniciar sesión solo aparece en modo login', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AuthPage(
          background: ColoredBox(color: Colors.black), // ✅ evita video
        ),
      ),
    );

    // ✅ En landing NO debe estar el botón principal
    expect(find.widgetWithText(ElevatedButton, 'Iniciar sesión'), findsNothing);

    await tester.tap(find.text('Inicia sesión ahora'));
    await tester.pumpAndSettle();

    // ✅ En login sí debe estar
    expect(
      find.widgetWithText(ElevatedButton, 'Iniciar sesión'),
      findsOneWidget,
    );
  });

  testWidgets('Toggle de visibilidad de contraseña funciona', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AuthPage(
          background: ColoredBox(color: Colors.black), // ✅ evita video
        ),
      ),
    );

    await tester.tap(find.text('Inicia sesión ahora'));
    await tester.pumpAndSettle();

    // ✅ Inicialmente obscure=true => icono visibility_off
    final eyeOff = find.byIcon(Icons.visibility_off);
    expect(eyeOff, findsOneWidget);

    await tester.tap(eyeOff);
    await tester.pump();

    // ✅ Después del tap cambia a visibility
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('Puede iniciar directamente en modo login (initialMode)', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AuthPage(
          initialMode: AuthMode.login,
          background: ColoredBox(color: Colors.black),
        ),
      ),
    );

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Iniciar sesión'),
      findsOneWidget,
    );
    expect(find.text('Registrarme con correo'), findsNothing);
  });
}

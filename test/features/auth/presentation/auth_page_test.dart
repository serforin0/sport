import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/presentation/pages/auth_landing_page.dart';

class _MockSharedPreferences extends Mock implements SharedPreferences {}

Widget _wrap(Widget child) {
  final preferences = _MockSharedPreferences();
  when(() => preferences.getString(any())).thenReturn(null);
  when(() => preferences.remove(any())).thenAnswer((_) async => true);
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
    child: MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(390, 844)),
        child: child,
      ),
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

    expect(find.text('REGISTRARSE'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsNothing);
  });

  testWidgets('Cambia a login al tocar ENTRAR', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AuthPage(
          background: ColoredBox(color: Colors.black), // ✅ evita video
        ),
      ),
    );

    await tester.tap(find.text('ENTRAR'));
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
          enableDemoLogin: false,
        ),
      ),
    );

    expect(find.widgetWithText(ElevatedButton, 'Iniciar sesión'), findsNothing);
    expect(find.text('USUARIO DE PRUEBA'), findsNothing);

    await tester.tap(find.text('ENTRAR'));
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

    await tester.tap(find.text('ENTRAR'));
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
    expect(find.text('REGISTRARSE'), findsNothing);
  });

  testWidgets('muestra acceso demo únicamente con feature gate activo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AuthPage(
          enableDemoLogin: true,
          background: ColoredBox(color: Colors.black),
        ),
      ),
    );

    expect(find.text('USUARIO DE PRUEBA'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/feed/presentation/pages/create_post_page.dart';
import 'package:sport/features/shell/main_shell.dart';

import '../support/e2e_harness.dart';

/// Journey 2: shell → chips Mi deporte → FAB crear post → publicar
void main() {
  e2eBinding();

  testWidgets('e2e_feed_scope_y_crear_publicacion', (tester) async {
    final prefs = await e2eInitPrefs(roleGuideDone: true);
    await e2ePumpApp(tester, prefs: prefs);

    await e2eTapDemoLogin(tester);
    await e2eCompleteRoleGuideIfPresent(tester);
    expect(find.byType(MainShell), findsOneWidget);

    // Scope chips
    final miDeporte = find.textContaining('Mi deporte');
    expect(miDeporte, findsOneWidget);
    await tester.tap(miDeporte);
    await tester.pump(const Duration(milliseconds: 500));

    final todos = find.text('Todos los deportes');
    expect(todos, findsOneWidget);
    await tester.tap(todos);
    await tester.pump(const Duration(milliseconds: 500));

    // FAB crear publicación
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(CreatePostPage), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).first,
      'E2E HubSport ${DateTime.now().millisecondsSinceEpoch}',
    );
    await tester.pump();

    // Tipo entrenamiento + ubicación
    final typeField = find.byType(DropdownButtonFormField<String>);
    if (typeField.evaluate().isNotEmpty) {
      await tester.tap(typeField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrenamiento').last);
      await tester.pumpAndSettle();
    }

    final location = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          (w.decoration?.labelText == 'Ubicación' ||
              w.decoration?.hintText == 'Ciudad, pista, estadio…'),
    );
    if (location.evaluate().isNotEmpty) {
      await tester.enterText(location, 'Pista E2E');
    }

    await tester.tap(find.text('Publicar'));
    await tester.pump();
    await e2eWaitForAny(
      tester,
      [
        find.textContaining('Publicación Exitosa'),
        find.byType(MainShell),
        find.text('Inicio'),
      ],
      timeout: const Duration(seconds: 45),
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}

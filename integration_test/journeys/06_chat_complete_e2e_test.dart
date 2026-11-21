import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/onboarding/presentation/pages/role_guide_page.dart';
import 'package:sport/features/shell/main_shell.dart';

import '../support/e2e_chat_journey.dart';
import '../support/e2e_harness.dart';

/// Journey chat completo (red real + demo).
void main() {
  e2eBinding();

  testWidgets('e2e_chat_completo', (tester) async {
    await e2eInitLocale();
    final oldOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final s = details.exceptionAsString();
      if (s.contains('HttpException') ||
          s.contains('statusCode: 404') ||
          s.contains('HTTP request failed') ||
          s.contains('LocaleDataException')) {
        return;
      }
      oldOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = oldOnError);

    final prefs = await e2eInitPrefs(roleGuideDone: true);
    await e2ePumpApp(tester, prefs: prefs);

    await e2eTapDemoLogin(tester);
    if (find.byType(RoleGuidePage).evaluate().isNotEmpty) {
      await e2eCompleteRoleGuideIfPresent(tester);
    }
    expect(find.byType(MainShell), findsOneWidget);

    await e2eChatCompleteJourney(tester);
  }, timeout: const Timeout(Duration(minutes: 5)));
}

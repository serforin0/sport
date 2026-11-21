import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/presentation/pages/auth_landing_page.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/onboarding/presentation/pages/role_guide_page.dart';
import 'package:sport/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:sport/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:sport/features/settings/presentation/providers/profile_providers.dart';
import 'package:sport/features/shell/main_shell.dart';
import 'package:sport/core/widgets/hubsport_wordmark.dart';

/// App mínima para E2E: sin video de login, demo login forzado.
class E2eApp extends ConsumerWidget {
  const E2eApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(onboardingDoneProvider);
    final authState = ref.watch(authControllerProvider);
    final cachedUser = authState.valueOrNull;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: onboardingDone.when(
        data: (done) {
          if (!done) {
            // En E2E el harness marca onboarding_done=true; fallback auth.
            return const AuthPage(
              enableDemoLogin: true,
              background: ColoredBox(color: Color(0xFF0F172A)),
            );
          }
          if (authState.isLoading) {
            return cachedUser != null
                ? const _E2ePostAuthHome()
                : const AuthPage(
                    enableDemoLogin: true,
                    background: ColoredBox(color: Color(0xFF0F172A)),
                  );
          }
          return authState.when(
            data: (user) {
              if (user == null) {
                return const AuthPage(
                  enableDemoLogin: true,
                  background: ColoredBox(color: Color(0xFF0F172A)),
                );
              }
              return const _E2ePostAuthHome();
            },
            loading: () => const AuthPage(
              enableDemoLogin: true,
              background: ColoredBox(color: Color(0xFF0F172A)),
            ),
            error: (_, _) => const AuthPage(
              enableDemoLogin: true,
              background: ColoredBox(color: Color(0xFF0F172A)),
            ),
          );
        },
        loading: () => const Scaffold(
          backgroundColor: Color(0xFF0033FF),
          body: Center(child: HubSportWordmark(fontSize: 36)),
        ),
        error: (_, _) => const AuthPage(
          enableDemoLogin: true,
          background: ColoredBox(color: Color(0xFF0F172A)),
        ),
      ),
    );
  }
}

class _E2ePostAuthHome extends ConsumerWidget {
  const _E2ePostAuthHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guideDone = ref.watch(roleGuideDoneProvider);
    return guideDone.when(
      data: (done) => done ? const MainShell() : const RoleGuidePage(),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const MainShell(),
    );
  }
}

Future<SharedPreferences> e2eInitPrefs({
  bool onboardingDone = true,
  bool roleGuideDone = false,
}) async {
  SharedPreferences.setMockInitialValues({
    'onboarding_done': onboardingDone,
    'role_guide_done': roleGuideDone,
  });
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', onboardingDone);
  await prefs.setBool('role_guide_done', roleGuideDone);
  await prefs.remove('auth_token');
  await prefs.remove('cached_user');
  return prefs;
}

Future<void> e2ePumpApp(
  WidgetTester tester, {
  required SharedPreferences prefs,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sharedPrefsInitProvider.overrideWith((ref) async => prefs),
        settingsLocalDataSourceProvider.overrideWithValue(
          SettingsLocalDataSourceImpl(prefs),
        ),
      ],
      child: const E2eApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> e2eTapDemoLogin(WidgetTester tester) async {
  // En dispositivo real no forzamos tamaño de escritorio
  final demo = find.text('USUARIO DE PRUEBA');
  expect(demo, findsOneWidget, reason: 'Demo login requiere enableDemoLogin');
  await tester.ensureVisible(demo);
  await tester.pumpAndSettle(const Duration(seconds: 1));
  await tester.tap(demo);
  await tester.pump();
  // Red de API: esperar shell, guía, o error visible
  await e2eWaitForAny(
    tester,
    [
      find.text('Empezar'),
      find.text('Inicio'),
      find.byType(MainShell),
      find.byType(RoleGuidePage),
      find.textContaining('demostración'),
      find.textContaining('No se pudo'),
    ],
    timeout: const Duration(seconds: 60),
  );
  if (find.textContaining('No se pudo').evaluate().isNotEmpty ||
      find.textContaining('demostración').evaluate().isNotEmpty &&
          find.byType(MainShell).evaluate().isEmpty &&
          find.byType(RoleGuidePage).evaluate().isEmpty) {
    fail('Demo login falló en UI (revisa red / entitlements macOS network.client)');
  }
}

Future<void> e2eCompleteRoleGuideIfPresent(WidgetTester tester) async {
  final start = find.text('Empezar');
  if (start.evaluate().isNotEmpty) {
    await tester.tap(start);
    await tester.pump();
    await e2eWaitForAny(
      tester,
      [find.text('Inicio'), find.byType(MainShell)],
      timeout: const Duration(seconds: 20),
    );
  }
}

Future<void> e2eWaitForAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    for (final f in finders) {
      if (f.evaluate().isNotEmpty) return;
    }
  }
  fail('Timeout E2E: ninguno de los finders apareció a tiempo');
}

void e2eBinding() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
}

/// Intl date labels (chat chips "Hoy"/"Ayer"/DateFormat es).
Future<void> e2eInitLocale() async {
  await initializeDateFormatting('es');
  await initializeDateFormatting('en');
}

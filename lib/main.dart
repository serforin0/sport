import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';

import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/auth_landing_page.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/presentation/providers/profile_providers.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/shell/main_shell.dart';
import 'features/onboarding/presentation/providers/onboarding_providers.dart';
import 'core/widgets/hubsport_wordmark.dart';

// Eliminado provider duplicado, se usa el de onboarding_providers.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          settingsLocalDataSourceProvider.overrideWithValue(
            SettingsLocalDataSourceImpl(sharedPreferences),
          ),
        ],
        child: const App(),
      ),
    );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(onboardingDoneProvider);
    final authState = ref.watch(authControllerProvider);
    final cachedUser = authState.valueOrNull;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: onboardingDone.when(
        data: (done) {
          if (!done) return const OnboardingPage();

          if (authState.isLoading) {
            return cachedUser != null ? const MainShell() : const AuthPage();
          }

          return authState.when(
            data: (user) => user != null ? const MainShell() : const AuthPage(),
            loading: () => const AuthPage(),
            error: (error, stackTrace) => const AuthPage(),
          );
        },
        loading: () => const _Splash(),
        error: (error, stackTrace) => const _Splash(),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0033FF), // Color azul marca HubSport
      body: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.8, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: (value - 0.8) / 0.2,
                child: child,
              ),
            );
          },
          child: const HubSportWordmark(fontSize: 42, letterSpacing: 2),
        ),
      ),
    );
  }
}

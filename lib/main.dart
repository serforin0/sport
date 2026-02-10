import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/auth/presentation/pages/auth_landing_page.dart';

// Lee si el onboarding ya se completó
final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_done') ?? false;
});

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(onboardingDoneProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: onboardingDone.when(
        data: (done) => done ? const AuthPage() : const OnboardingPage(),
        loading: () => const _Splash(),
        error: (error, stack) => const _Splash(),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

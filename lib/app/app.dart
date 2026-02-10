import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/auth_landing_page.dart';
import '../features/onboarding/presentation/providers/onboarding_providers.dart';

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
        error: (error, stack) =>
            const _Splash(), // puedes mostrar error si quieres
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

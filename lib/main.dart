import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/profile/presentation/pages/profile_page.dart';

// ... (existing imports)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          SettingsRepositoryImpl(SettingsLocalDataSourceImpl(sharedPreferences)),
        ),
        authRepositoryProvider.overrideWithValue(
          AuthRepositoryImpl(sharedPreferences),
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: onboardingDone.when(
        data: (done) {
          if (!done) return const OnboardingPage();
          
          return authState.when(
            data: (user) => user != null ? const ProfilePage() : const AuthPage(),
            loading: () => const _Splash(),
            error: (_, __) => const AuthPage(),
          );
        },
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
          child: const Text(
            'HUBSPORT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider must be overridden');
});

final sharedPrefsInitProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPrefsInitProvider.future);
  return prefs.getBool('onboarding_done') ?? false;
});

final roleGuideDoneProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPrefsInitProvider.future);
  return prefs.getBool('role_guide_done') ?? false;
});

final onboardingActionsProvider = Provider<OnboardingActions>((ref) {
  return OnboardingActions(ref);
});

class OnboardingActions {
  final Ref ref;
  OnboardingActions(this.ref);

  Future<void> markDone() async {
    final prefs = await ref.read(sharedPrefsInitProvider.future);
    await prefs.setBool('onboarding_done', true);
    ref.invalidate(onboardingDoneProvider);
  }

  Future<void> markRoleGuideDone() async {
    final prefs = await ref.read(sharedPrefsInitProvider.future);
    await prefs.setBool('role_guide_done', true);
    ref.invalidate(roleGuideDoneProvider);
  }
}

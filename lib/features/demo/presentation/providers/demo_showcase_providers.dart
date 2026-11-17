import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/demo/data/repositories/demo_showcase_repository_impl.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';
import 'package:sport/features/demo/domain/repositories/demo_showcase_repository.dart';

final demoShowcaseRepositoryProvider = Provider<DemoShowcaseRepository>((ref) {
  return DemoShowcaseRepositoryImpl(ref.watch(apiClientProvider));
});

final demoShowcaseProvider = FutureProvider<DemoShowcase>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user?.demoPreview != true) {
    throw Exception('El showcase está disponible solo para el usuario demo');
  }

  final result = await ref.read(demoShowcaseRepositoryProvider).getShowcase();
  return result.fold(
    (failure) => throw StateError(failure.message),
    (showcase) => showcase,
  );
});

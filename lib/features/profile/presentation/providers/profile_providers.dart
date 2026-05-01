import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';

final profileProvider = FutureProvider.family<User, String>((ref, userId) async {
  final repository = ref.watch(authRepositoryProvider);
  final result = await repository.getProfile(userId);
  return result.fold(
    (failure) => throw failure.message,
    (user) => user,
  );
});

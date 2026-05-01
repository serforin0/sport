import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/references/data/repositories/references_repository.dart';
import 'package:sport/features/references/domain/entities/reference_request.dart';
import 'package:sport/features/references/domain/entities/sports_reference.dart';

final referencesRepositoryProvider = Provider<ReferencesRepository>((ref) {
  return ReferencesRepository(ref.watch(apiClientProvider));
});

final referencesInboxProvider = FutureProvider.autoDispose<ReferencesInbox>((ref) async {
  final result = await ref.watch(referencesRepositoryProvider).getInbox();
  return result.fold((failure) => throw Exception(failure.message), (inbox) => inbox);
});

final publishedReferencesProvider = FutureProvider.autoDispose.family<List<SportsReference>, String>((ref, userId) async {
  final result = await ref.watch(referencesRepositoryProvider).getPublishedForUser(userId);
  return result.fold((failure) => throw Exception(failure.message), (references) => references);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/sponsorships/data/repositories/sponsorships_repository.dart';

final sponsorshipsRepositoryProvider = Provider<SponsorshipsRepository>((ref) {
  return SponsorshipsRepository(ref.watch(apiClientProvider));
});

final sponsorshipsListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final result = await ref.watch(sponsorshipsRepositoryProvider).listSponsorships();
  return result.fold((failure) => throw Exception(failure.message), (items) => items);
});

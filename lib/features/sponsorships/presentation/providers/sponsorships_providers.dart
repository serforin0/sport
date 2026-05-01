import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/features/sponsorships/data/repositories/sponsorships_repository.dart';

final sponsorshipsRepositoryProvider = Provider<SponsorshipsRepository>((ref) {
  return SponsorshipsRepository(ref.watch(apiClientProvider));
});

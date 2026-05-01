import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import '../../data/support_remote_datasource.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((ref) {
  return SupportRemoteDataSource(ref.watch(apiClientProvider));
});

final helpContentProvider = FutureProvider<dynamic>((ref) async {
  return ref.watch(supportRemoteDataSourceProvider).fetchHelp();
});

final billingSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final token = prefs.getString('auth_token');
  if (token == null) return {};
  return ref.watch(supportRemoteDataSourceProvider).fetchBillingSummary(token);
});

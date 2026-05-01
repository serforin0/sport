import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import '../../data/datasources/connections_remote_datasource.dart';
import '../../domain/entities/connected_contact.dart';
import '../../domain/entities/pending_connection.dart';

final connectionsRemoteDataSourceProvider = Provider<ConnectionsRemoteDataSource>((ref) {
  return ConnectionsRemoteDataSource(ref.watch(apiClientProvider));
});

/// Amigos aceptados (`GET /connections`).
final acceptedConnectionsProvider = FutureProvider<List<ConnectedContact>>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final token = prefs.getString('auth_token');
  if (token == null) return [];
  return ref.watch(connectionsRemoteDataSourceProvider).fetchAcceptedConnections(token);
});

final acceptedConnectionsCountProvider = Provider<int>((ref) {
  final async = ref.watch(acceptedConnectionsProvider);
  return async.maybeWhen(data: (list) => list.length, orElse: () => 0);
});

final incomingConnectionsProvider =
    AsyncNotifierProvider<IncomingConnectionsNotifier, List<PendingConnection>>(
  IncomingConnectionsNotifier.new,
);

class IncomingConnectionsNotifier extends AsyncNotifier<List<PendingConnection>> {
  @override
  Future<List<PendingConnection>> build() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    if (token == null) return [];
    return ref.read(connectionsRemoteDataSourceProvider).fetchIncoming(token);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.read(sharedPreferencesProvider);
      final token = prefs.getString('auth_token');
      if (token == null) return <PendingConnection>[];
      return ref.read(connectionsRemoteDataSourceProvider).fetchIncoming(token);
    });
  }

  Future<void> accept(String connectionId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    if (token == null) return;
    await ref.read(connectionsRemoteDataSourceProvider).accept(token, connectionId);
    await refresh();
  }

  Future<void> reject(String connectionId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    if (token == null) return;
    await ref.read(connectionsRemoteDataSourceProvider).reject(token, connectionId);
    await refresh();
  }
}

final connectionRequestsCountProvider = Provider<int>((ref) {
  final async = ref.watch(incomingConnectionsProvider);
  return async.maybeWhen(data: (list) => list.length, orElse: () => 0);
});

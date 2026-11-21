import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';
import 'package:sport/features/auth/data/models/user_model.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/profile/presentation/pages/user_profile_page.dart';

final connectionCircleProvider =
    FutureProvider.autoDispose.family<({int connections, int mutuals, List<User> peers, Set<String> mutualIds}), String>((
  ref,
  userId,
) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/connections/users/$userId/circle');
  final data = unwrapDataMap(response.data) ?? {};
  final userMeta = data['user'] is Map ? Map<String, dynamic>.from(data['user'] as Map) : <String, dynamic>{};
  final peers = unwrapDataList(data['connections'] ?? data)
      .whereType<Map>()
      .map((e) => UserModel.fromMap(Map<String, dynamic>.from(e)) as User)
      .toList();
  final mutualIds = (data['mutual_ids'] is List ? data['mutual_ids'] as List : const [])
      .map((e) => e.toString())
      .toSet();
  return (
    connections: int.tryParse('${userMeta['connections_count'] ?? peers.length}') ?? peers.length,
    mutuals: int.tryParse('${userMeta['mutual_connections_count'] ?? 0}') ?? 0,
    peers: peers,
    mutualIds: mutualIds,
  );
});

class ConnectionCirclePage extends ConsumerWidget {
  final String userId;
  final String? userName;

  const ConnectionCirclePage({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(connectionCircleProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          userName == null ? 'Conexiones' : 'Conexiones de $userName',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${data.connections} conexiones · ${data.mutuals} en común',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if (data.peers.isEmpty)
                const Text(
                  'Sin conexiones todavía.',
                  style: TextStyle(color: Colors.white54),
                )
              else
                ...data.peers.map((peer) {
                  final isMutual = data.mutualIds.contains(peer.id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white12,
                      backgroundImage: peer.photoUrl != null
                          ? NetworkImage(peer.photoUrl!)
                          : null,
                      child: peer.photoUrl == null
                          ? const Icon(Icons.person, color: Colors.white54)
                          : null,
                    ),
                    title: Text(
                      peer.name ?? 'Usuario',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      [
                        if (peer.handle != null) peer.handle!,
                        if (isMutual) 'En común',
                      ].join(' · '),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfilePage(userId: peer.id),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

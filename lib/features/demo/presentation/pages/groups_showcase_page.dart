import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/demo/presentation/pages/group_detail_page.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';
import 'package:sport/features/demo/presentation/widgets/demo_error_view.dart';

class GroupsShowcasePage extends ConsumerWidget {
  const GroupsShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showcase = ref.watch(demoShowcaseProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('Grupos'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: DemoBadge()),
          ),
        ],
      ),
      body: showcase.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Cargando grupos'),
        ),
        error: (_, _) => DemoErrorView(
          message: 'No se pudieron cargar los grupos de demostración.',
          onRetry: () => ref.invalidate(demoShowcaseProvider),
        ),
        data: (data) {
          if (data.groups.isEmpty) {
            return const Center(
              child: Text(
                'No hay grupos en el entorno demo',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final group = data.groups[index];
              return ListTile(
                tileColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: CircleAvatar(
                  backgroundImage: group.imageUrl == null
                      ? null
                      : CachedNetworkImageProvider(group.imageUrl!),
                  child: group.imageUrl == null
                      ? const Icon(Icons.groups_outlined)
                      : null,
                ),
                title: Text(
                  group.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  [
                    '${group.membersCount} miembros',
                    if (group.joined) 'Miembro',
                    if (group.description != null) group.description!,
                  ].join(' · '),
                  style: const TextStyle(color: Colors.white60),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => GroupDetailPage(group: group),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

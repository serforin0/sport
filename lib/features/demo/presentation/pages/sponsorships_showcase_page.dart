import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/demo/presentation/pages/sponsorship_detail_page.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';
import 'package:sport/features/demo/presentation/widgets/demo_error_view.dart';
import 'package:sport/features/sponsorships/presentation/pages/create_sponsorship_page.dart';

class SponsorshipsShowcasePage extends ConsumerWidget {
  const SponsorshipsShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showcase = ref.watch(demoShowcaseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('Patrocinios'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Center(child: DemoBadge()),
          ),
          IconButton(
            tooltip: 'Crear patrocinio',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateSponsorshipPage()),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: showcase.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Cargando patrocinios',
          ),
        ),
        error: (_, _) => DemoErrorView(
          message: 'No se pudieron cargar los patrocinios.',
          onRetry: () => ref.invalidate(demoShowcaseProvider),
        ),
        data: (data) {
          if (data.collaborations.isEmpty) {
            return const Center(
              child: Text(
                'No hay patrocinios en el entorno demo',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.collaborations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = data.collaborations[index];
              return Card(
                color: const Color(0xFF1E293B),
                child: ListTile(
                  leading: const Icon(
                    Icons.workspace_premium_outlined,
                    color: Color(0xFFFBBF24),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    [item.partner, item.sport, item.status]
                        .whereType<String>()
                        .where((value) => value.isNotEmpty)
                        .join(' · '),
                    style: const TextStyle(color: Colors.white60),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => SponsorshipDetailPage(sponsorship: item),
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';
import 'package:sport/features/demo/presentation/widgets/demo_badge.dart';
import 'package:sport/features/demo/presentation/widgets/demo_error_view.dart';

class CollaborationsShowcasePage extends ConsumerWidget {
  const CollaborationsShowcasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showcase = ref.watch(demoShowcaseProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: const Text('Colaboración'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: DemoBadge()),
          ),
        ],
      ),
      body: showcase.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Cargando colaboraciones',
          ),
        ),
        error: (_, _) => DemoErrorView(
          message: 'No se pudieron cargar las colaboraciones.',
          onRetry: () => ref.invalidate(demoShowcaseProvider),
        ),
        data: (data) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.collaborations.length,
          itemBuilder: (context, index) {
            final item = data.collaborations[index];
            return Card(
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(label: Text(item.status)),
                      ],
                    ),
                    if (item.partner != null)
                      Text(
                        item.partner!,
                        style: const TextStyle(color: Color(0xFF5EEAD4)),
                      ),
                    if (item.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

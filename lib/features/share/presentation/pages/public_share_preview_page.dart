import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/network/api_client.dart';
import 'package:sport/core/network/json_api_utils.dart';

final publicShareProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, ({String type, String id})>((
  ref,
  args,
) async {
  final client = ref.watch(apiClientProvider);
  final path = args.type == 'news'
      ? '/public/sport/news/${args.id}'
      : '/public/posts/${args.id}';
  final response = await client.get(path);
  return unwrapDataMap(response.data) ??
      (response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{});
});

/// Vista de cómo se ve un post/noticia sin cuenta (CTA de registro).
class PublicSharePreviewPage extends ConsumerWidget {
  final String type; // post | news
  final String id;

  const PublicSharePreviewPage({
    super.key,
    required this.type,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicShareProvider((type: type, id: id)));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vista pública',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          final cta = data['cta'] is Map
              ? Map<String, dynamic>.from(data['cta'] as Map)
              : <String, dynamic>{};
          final post = data['post'];
          final news = data['news'];
          String title = '';
          String body = '';
          if (post is Map) {
            title = (post['title'] ?? '').toString();
            body = (post['body'] ?? '').toString();
          } else if (news is Map) {
            title = (news['title'] ?? '').toString();
            body = (news['content'] ?? news['body'] ?? '').toString();
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                title.isEmpty ? 'Contenido HubSport' : title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cta['message']?.toString() ??
                          'Crea una cuenta para ver más en HubSport.',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Comentarios, conexiones y el resto del contenido quedan detrás del registro.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

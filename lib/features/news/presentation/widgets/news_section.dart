import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/news_providers.dart';
import '../pages/all_news_page.dart';
import 'news_card.dart';
import 'news_card_skeleton.dart';

class NewsSection extends ConsumerWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(sportsNewsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Noticias Destacadas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllNewsPage()),
                ),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: newsAsync.when(
            data: (articles) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return NewsCard(article: articles[index]);
              },
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) => const NewsCardSkeleton(),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No se pudieron cargar las noticias',
                  style: TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

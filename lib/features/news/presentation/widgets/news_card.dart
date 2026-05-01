import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/news_article.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen con altura fija
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.urlToImage != null)
                    Image.network(
                      article.urlToImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                    )
                  else
                    const _PlaceholderImage(),

                  // Badge de fuente
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.source.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Área de texto con padding fijo
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.description,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMM • HH:mm').format(article.publishedAt),
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white10,
      child: const Center(
        child: Icon(Icons.newspaper_outlined, color: Colors.white24, size: 40),
      ),
    );
  }
}

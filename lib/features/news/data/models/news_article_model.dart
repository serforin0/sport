import '../../domain/entities/news_article.dart';

class NewsArticleModel extends NewsArticle {
  const NewsArticleModel({
    required super.title,
    required super.description,
    required super.url,
    super.urlToImage,
    required super.source,
    required super.publishedAt,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      source: json['source'] != null ? json['source']['name'] ?? 'Noticia' : 'Noticia',
      publishedAt: DateTime.parse(json['publishedAt']),
    );
  }

  /// Respuesta del API Hubsport (`GET /sport/news`) u objetos con claves snake_case.
  factory NewsArticleModel.fromHubApi(Map<String, dynamic> json) {
    final publishedRaw =
        json['published_at'] ?? json['publishedAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String();
    DateTime publishedAt;
    try {
      publishedAt = DateTime.parse(publishedRaw.toString());
    } catch (_) {
      publishedAt = DateTime.now();
    }
    final sourceMap = json['source'];
    final sourceName = json['source_name']?.toString() ??
        (sourceMap is Map ? sourceMap['name']?.toString() : null) ??
        'Noticia';
    return NewsArticleModel(
      title: json['title']?.toString() ?? '',
      description: (json['description'] ?? json['summary'] ?? json['excerpt'] ?? '').toString(),
      url: (json['url'] ?? json['link'] ?? json['slug'] ?? '').toString(),
      urlToImage: json['url_to_image']?.toString() ?? json['urlToImage']?.toString() ?? json['image_url']?.toString(),
      source: sourceName,
      publishedAt: publishedAt,
    );
  }
}

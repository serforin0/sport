class NewsArticle {
  final String? id;
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String source;
  final DateTime publishedAt;

  const NewsArticle({
    this.id,
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.source,
    required this.publishedAt,
  });
}

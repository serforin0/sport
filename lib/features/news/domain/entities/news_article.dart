class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String source;
  final DateTime publishedAt;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.source,
    required this.publishedAt,
  });
}

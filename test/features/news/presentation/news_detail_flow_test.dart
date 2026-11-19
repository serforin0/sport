import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/news/domain/entities/news_article.dart';
import 'package:sport/features/news/presentation/pages/news_detail_page.dart';
import 'package:sport/features/news/presentation/widgets/news_card.dart';

void main() {
  final article = NewsArticle(
    title: 'Atleta gana oro',
    description: 'Detalle de la competencia.',
    url: 'https://example.test/news/1',
    source: 'HubSport',
    publishedAt: DateTime(2026, 11, 18),
  );

  testWidgets('NewsCard navega al detalle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NewsCard(article: article)),
      ),
    );

    await tester.tap(find.byType(NewsCard));
    await tester.pumpAndSettle();

    expect(find.byType(NewsDetailPage), findsOneWidget);
    expect(find.text('Atleta gana oro'), findsOneWidget);
    expect(find.textContaining('Detalle de la competencia'), findsOneWidget);
  });
}

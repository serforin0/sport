import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/feed/presentation/providers/feed_providers.dart';

void main() {
  testWidgets('feedSportScopeProvider cambia entre mi deporte y todos', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final scope = ref.watch(feedSportScopeProvider);
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Text(scope),
                    TextButton(
                      onPressed: () =>
                          ref.read(feedSportScopeProvider.notifier).state =
                              'my_sport',
                      child: const Text('mi'),
                    ),
                    TextButton(
                      onPressed: () =>
                          ref.read(feedSportScopeProvider.notifier).state =
                              'all',
                      child: const Text('todos'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('all'), findsOneWidget);
    await tester.tap(find.text('mi'));
    await tester.pump();
    expect(find.text('my_sport'), findsOneWidget);
    await tester.tap(find.text('todos'));
    await tester.pump();
    expect(find.text('all'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sport/core/result/result.dart';
import 'package:sport/features/demo/domain/entities/demo_showcase.dart';
import 'package:sport/features/demo/domain/repositories/demo_showcase_repository.dart';
import 'package:sport/features/demo/presentation/pages/store_product_page.dart';
import 'package:sport/features/demo/presentation/providers/demo_showcase_providers.dart';

class MockDemoShowcaseRepository extends Mock
    implements DemoShowcaseRepository {}

void main() {
  late MockDemoShowcaseRepository repo;

  const product = DemoStoreProduct(
    id: 'prd_demo_spikes',
    name: 'Clavos de pista 400 m',
    description: 'Calzado técnico',
    price: '89',
    currency: 'USD',
    affiliateUrl: 'https://www.amazon.com/s?k=track+spikes',
    variants: ['38', '39', '41'],
  );

  setUp(() {
    repo = MockDemoShowcaseRepository();
    when(
      () => repo.checkout(
        productId: any(named: 'productId'),
        variant: any(named: 'variant'),
        recipientName: any(named: 'recipientName'),
        city: any(named: 'city'),
        address: any(named: 'address'),
      ),
    ).thenAnswer(
      (_) async => const Ok({
        'id': 'ord_demo_cert',
        'product_name': 'Clavos de pista 400 m',
        'variant': '41',
        'amount': 89.0,
        'currency': 'USD',
        'commission_percent': 12.0,
        'commission_amount': 10.68,
        'net_amount': 78.32,
        'recipient_name': 'Sofía Ramírez',
        'address': 'Centro Olímpico, pista 1',
        'city': 'Santo Domingo',
      }),
    );
  });

  testWidgets('seleccionar_variante_choice_chip', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoShowcaseRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: StoreProductPage(product: product)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('41'), findsOneWidget);
    await tester.tap(find.text('41'));
    await tester.pumpAndSettle();
    // Chip selected — still visible
    expect(find.text('41'), findsOneWidget);
  });

  testWidgets('tap_pagar_navega_a_StoreReceiptPage_con_comision_12', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoShowcaseRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: StoreProductPage(product: product)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('41'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pagar y confirmar pedido'));
    await tester.pumpAndSettle();

    verify(
      () => repo.checkout(
        productId: 'prd_demo_spikes',
        variant: '41',
        recipientName: any(named: 'recipientName'),
        city: any(named: 'city'),
        address: any(named: 'address'),
      ),
    ).called(1);

    expect(find.byType(StoreReceiptPage), findsOneWidget);
    expect(find.text('Pedido confirmado'), findsOneWidget);
    expect(find.textContaining('Comisión HubSport (12.0%)'), findsOneWidget);
    expect(find.textContaining('10.68'), findsOneWidget);
  });

  testWidgets('tap_volver_a_tienda_hace_pop', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StoreReceiptPage(
          order: {
            'id': 'ord_1',
            'product_name': 'Clavos',
            'variant': '41',
            'amount': 89,
            'currency': 'USD',
            'commission_percent': 12.0,
            'commission_amount': 10.68,
            'net_amount': 78.32,
            'recipient_name': 'A',
            'address': 'B',
            'city': 'C',
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Volver a la tienda'));
    await tester.pumpAndSettle();

    expect(find.byType(StoreReceiptPage), findsNothing);
  });

  testWidgets('tap_ver_en_tienda_copia_affiliateUrl', (tester) async {
    final clipped = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        clipped.add(call);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoShowcaseRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: StoreProductPage(product: product)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver en tienda (afiliado)'));
    await tester.pumpAndSettle();

    expect(
      clipped.any(
        (c) =>
            c.method == 'Clipboard.setData' &&
            c.arguments.toString().contains('amazon.com'),
      ),
      isTrue,
    );
    expect(find.textContaining('Enlace de tienda copiado'), findsOneWidget);
  });
}

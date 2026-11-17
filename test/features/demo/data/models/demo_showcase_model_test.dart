import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/demo/data/models/demo_showcase_model.dart';

void main() {
  test('parsea el showcase completo sin conservar JSON crudo', () {
    final showcase = DemoShowcaseModel.fromMap(const {
      'billing': {
        'subscription': {
          'name': 'Profesional',
          'status': 'active',
          'price': '19.99',
          'currency': 'EUR',
        },
        'payment_methods': [
          {
            'id': 'pm_demo',
            'brand': 'Visa',
            'last4': '4242',
            'expiry': '12/30',
            'is_default': true,
          },
        ],
        'invoices': [
          {
            'id': 'INV-DEMO-1',
            'number': 'DEMO-2026-001',
            'date': '2026-08-01',
            'amount': '19.99',
            'currency': 'EUR',
            'status': 'paid',
            'description': 'Plan profesional',
            'download_url': '/api/v1/demo/invoices/INV-DEMO-1/pdf',
          },
        ],
      },
      'groups': [
        {
          'id': 1,
          'name': 'Atletas Madrid',
          'members_count': 24,
          'image_url': 'https://example.test/group.jpg',
          'role': 'visitor',
          'posts': [
            {'id': 'post-1', 'author': 'Ana', 'body': 'Entrenamiento'},
          ],
        },
      ],
      'collaborations': [
        {
          'id': 2,
          'title': 'Campus inclusivo',
          'status': 'open',
          'partner': 'Fundación',
          'sport': 'Atletismo',
          'benefits': 'Material',
          'requirements': 'Disponibilidad',
          'contact': 'alianzas@example.test',
        },
      ],
      'store_products': [
        {
          'id': 3,
          'name': 'Balón',
          'price': '29.90',
          'currency': 'EUR',
          'variants': ['M', 'L'],
        },
      ],
    });

    expect(showcase.billing.subscription?.name, 'Profesional');
    expect(showcase.billing.paymentMethods.single.last4, '4242');
    expect(showcase.billing.paymentMethods.single.expiry, '12/30');
    expect(showcase.billing.invoices.single.id, 'INV-DEMO-1');
    expect(showcase.billing.invoices.single.number, 'DEMO-2026-001');
    expect(
      showcase.billing.invoices.single.downloadUrl,
      '/api/v1/demo/invoices/INV-DEMO-1/pdf',
    );
    expect(showcase.groups.single.membersCount, 24);
    expect(showcase.groups.single.joined, isFalse);
    expect(showcase.groups.single.posts.single.author, 'Ana');
    expect(showcase.storeProducts.single.name, 'Balón');
    expect(showcase.collaborations.single.title, 'Campus inclusivo');
    expect(showcase.collaborations.single.benefits, 'Material');
    expect(showcase.storeProducts.single.variants, ['M', 'L']);

    final encoded = showcase.toMap();
    expect(encoded['billing'], isA<Map<String, dynamic>>());
    expect((encoded['store_products'] as List).single['name'], 'Balón');
  });

  test('acepta expires del contrato demo de facturación', () {
    final showcase = DemoShowcaseModel.fromMap(const {
      'billing': {
        'subscription': {'plan': 'HubSport Pro Demo', 'status': 'active'},
        'payment_methods': [
          {'id': 'pm', 'brand': 'visa', 'last4': '4242', 'expires': '12/30'},
        ],
        'invoices': [],
      },
      'groups': [],
      'collaborations': [],
      'store_products': [],
    });

    expect(showcase.billing.paymentMethods.single.expiry, '12/30');
    expect(showcase.billing.subscription?.name, 'HubSport Pro Demo');
  });
}

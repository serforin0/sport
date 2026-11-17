import 'package:sport/features/demo/domain/entities/demo_showcase.dart';

class DemoShowcaseModel extends DemoShowcase {
  const DemoShowcaseModel({
    required super.billing,
    required super.groups,
    required super.collaborations,
    required super.storeProducts,
  });

  factory DemoShowcaseModel.fromMap(Map<String, dynamic> map) {
    final billing = _map(map['billing']);
    return DemoShowcaseModel(
      billing: DemoBilling(
        subscription: _subscription(billing['subscription']),
        paymentMethods: _list(
          billing['payment_methods'],
        ).map(_paymentMethod).toList(growable: false),
        invoices: _list(
          billing['invoices'],
        ).map(_invoice).toList(growable: false),
      ),
      groups: _list(map['groups']).map(_group).toList(growable: false),
      collaborations: _list(
        map['collaborations'],
      ).map(_collaboration).toList(growable: false),
      storeProducts: _list(
        map['store_products'],
      ).map(_storeProduct).toList(growable: false),
    );
  }

  Map<String, dynamic> toMap() {
    final subscription = billing.subscription;
    return {
      'billing': {
        'subscription': subscription == null
            ? null
            : {
                'name': subscription.name,
                'status': subscription.status,
                'price': subscription.price,
                'currency': subscription.currency,
                'renewal_date': subscription.renewalDate,
              },
        'payment_methods': billing.paymentMethods
            .map(
              (method) => {
                'id': method.id,
                'brand': method.brand,
                'last4': method.last4,
                'expiry': method.expiry,
                'is_default': method.isDefault,
              },
            )
            .toList(growable: false),
        'invoices': billing.invoices
            .map(
              (invoice) => {
                'id': invoice.id,
                'number': invoice.number,
                'date': invoice.date,
                'amount': invoice.amount,
                'currency': invoice.currency,
                'status': invoice.status,
                'description': invoice.description,
                'download_url': invoice.downloadUrl,
              },
            )
            .toList(growable: false),
      },
      'groups': groups
          .map(
            (group) => {
              'id': group.id,
              'name': group.name,
              'description': group.description,
              'members_count': group.membersCount,
              'image_url': group.imageUrl,
              'joined': group.joined,
            },
          )
          .toList(growable: false),
      'collaborations': collaborations
          .map(
            (collaboration) => {
              'id': collaboration.id,
              'title': collaboration.title,
              'description': collaboration.description,
              'status': collaboration.status,
              'partner': collaboration.partner,
            },
          )
          .toList(growable: false),
      'store_products': storeProducts
          .map(
            (product) => {
              'id': product.id,
              'name': product.name,
              'description': product.description,
              'price': product.price,
              'currency': product.currency,
              'image_url': product.imageUrl,
              'affiliate_url': product.affiliateUrl,
            },
          )
          .toList(growable: false),
    };
  }
}

DemoSubscription? _subscription(dynamic value) {
  final map = _map(value);
  if (map.isEmpty) return null;
  return DemoSubscription(
    name: _text(map['name'] ?? map['plan'], fallback: 'Plan demo'),
    status: _text(map['status'], fallback: 'active'),
    price: _text(map['price'] ?? map['amount'], fallback: '0'),
    currency: _text(map['currency'], fallback: 'EUR'),
    renewalDate: _nullableText(map['renewal_date'] ?? map['renews_at']),
  );
}

DemoPaymentMethod _paymentMethod(Map<String, dynamic> map) {
  return DemoPaymentMethod(
    id: _text(map['id']),
    brand: _text(map['brand'], fallback: 'Tarjeta'),
    last4: _text(map['last4'], fallback: '••••'),
    expiry: _nullableText(map['expiry'] ?? map['expires'] ?? map['expires_at']),
    isDefault: map['is_default'] == true || map['default'] == true,
  );
}

DemoInvoice _invoice(Map<String, dynamic> map) {
  return DemoInvoice(
    id: _text(map['id'] ?? map['number']),
    number: _text(map['number'] ?? map['id']),
    date: _text(map['date'] ?? map['issued_at']),
    amount: _text(map['amount'] ?? map['total'], fallback: '0'),
    currency: _text(map['currency'], fallback: 'EUR'),
    status: _text(map['status'], fallback: 'paid'),
    description: _text(map['description'], fallback: 'Suscripción HubSport'),
    downloadUrl: _nullableText(map['download_url']),
  );
}

DemoGroup _group(Map<String, dynamic> map) {
  return DemoGroup(
    id: _text(map['id']),
    name: _text(map['name'], fallback: 'Grupo deportivo'),
    description: _nullableText(map['description']),
    membersCount: _integer(map['members_count'] ?? map['members']),
    imageUrl: _nullableText(map['image_url'] ?? map['image']),
    joined:
        map['joined'] == true ||
        map['role'] == 'member' ||
        map['role'] == 'admin',
    posts: _list(map['posts']).map(_groupPost).toList(growable: false),
  );
}

DemoGroupPost _groupPost(Map<String, dynamic> map) {
  return DemoGroupPost(
    id: _text(map['id']),
    author: _text(map['author'], fallback: 'Miembro'),
    body: _text(map['body'] ?? map['content']),
  );
}

DemoCollaboration _collaboration(Map<String, dynamic> map) {
  return DemoCollaboration(
    id: _text(map['id']),
    title: _text(map['title'] ?? map['name'], fallback: 'Colaboración'),
    description: _nullableText(map['description']),
    status: _text(map['status'], fallback: 'open'),
    partner: _nullableText(map['partner'] ?? map['organization']),
    sport: _nullableText(map['sport']),
    benefits: _nullableText(map['benefits']),
    requirements: _nullableText(map['requirements']),
    contact: _nullableText(map['contact']),
  );
}

DemoStoreProduct _storeProduct(Map<String, dynamic> map) {
  return DemoStoreProduct(
    id: _text(map['id']),
    name: _text(map['name'], fallback: 'Producto deportivo'),
    description: _nullableText(map['description']),
    price: _text(map['price'], fallback: '0'),
    currency: _text(map['currency'], fallback: 'EUR'),
    imageUrl: _nullableText(map['image_url'] ?? map['image']),
    affiliateUrl: _nullableText(map['affiliate_url'] ?? map['url']),
    variants: _stringList(map['variants']),
  );
}

Map<String, dynamic> _map(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

String? _nullableText(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

int _integer(dynamic value) {
  return value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}

List<String> _stringList(dynamic value) {
  if (value is! List || value.isEmpty) return const ['Único'];
  return value
      .map((item) => item.toString())
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

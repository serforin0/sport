class DemoShowcase {
  final DemoBilling billing;
  final List<DemoGroup> groups;
  final List<DemoCollaboration> collaborations;
  final List<DemoStoreProduct> storeProducts;

  const DemoShowcase({
    required this.billing,
    required this.groups,
    required this.collaborations,
    required this.storeProducts,
  });
}

class DemoBilling {
  final DemoSubscription? subscription;
  final List<DemoPaymentMethod> paymentMethods;
  final List<DemoInvoice> invoices;

  const DemoBilling({
    this.subscription,
    this.paymentMethods = const [],
    this.invoices = const [],
  });
}

class DemoSubscription {
  final String name;
  final String status;
  final String price;
  final String currency;
  final String? renewalDate;

  const DemoSubscription({
    required this.name,
    required this.status,
    required this.price,
    required this.currency,
    this.renewalDate,
  });
}

class DemoPaymentMethod {
  final String id;
  final String brand;
  final String last4;
  final String? expiry;
  final bool isDefault;

  const DemoPaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    this.expiry,
    this.isDefault = false,
  });
}

class DemoInvoice {
  final String id;
  final String number;
  final String date;
  final String amount;
  final String currency;
  final String status;
  final String description;
  final String? downloadUrl;

  const DemoInvoice({
    required this.id,
    required this.number,
    required this.date,
    required this.amount,
    required this.currency,
    required this.status,
    required this.description,
    this.downloadUrl,
  });
}

class DemoGroup {
  final String id;
  final String name;
  final String? description;
  final int membersCount;
  final String? imageUrl;
  final bool joined;
  final List<DemoGroupPost> posts;

  const DemoGroup({
    required this.id,
    required this.name,
    this.description,
    this.membersCount = 0,
    this.imageUrl,
    this.joined = false,
    this.posts = const [],
  });
}

class DemoGroupPost {
  final String id;
  final String author;
  final String body;

  const DemoGroupPost({
    required this.id,
    required this.author,
    required this.body,
  });
}

class DemoCollaboration {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String? partner;
  final String? sport;
  final String? benefits;
  final String? requirements;
  final String? contact;

  const DemoCollaboration({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.partner,
    this.sport,
    this.benefits,
    this.requirements,
    this.contact,
  });
}

class DemoStoreProduct {
  final String id;
  final String name;
  final String? description;
  final String price;
  final String currency;
  final String? imageUrl;
  final String? affiliateUrl;
  final List<String> variants;

  const DemoStoreProduct({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.currency,
    this.imageUrl,
    this.affiliateUrl,
    this.variants = const ['Único'],
  });
}

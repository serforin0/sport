class Sport {
  final String id;
  final String name;
  final String? icon;

  Sport({required this.id, required this.name, this.icon});

  factory Sport.fromMap(Map<String, dynamic> map) {
    return Sport(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      icon: map['icon']?.toString(),
    );
  }
}

class Country {
  final String id;
  final String name;
  final String code;

  Country({required this.id, required this.name, required this.code});

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
    );
  }
}

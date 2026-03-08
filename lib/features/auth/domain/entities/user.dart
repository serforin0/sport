class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ name.hashCode ^ photoUrl.hashCode;

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

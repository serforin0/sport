import 'package:sport/features/auth/data/models/user_model.dart';

/// Fila de usuario (búsqueda / sugerencias / contactos) con línea tipo rol · deporte · país.
class PeopleListUser {
  final UserModel user;
  final String detailLine;

  const PeopleListUser({required this.user, required this.detailLine});

  static String formatDetailLine(Map<String, dynamic> m) {
    final p = m['profile'];
    Map<String, dynamic>? prof;
    if (p is Map) {
      prof = Map<String, dynamic>.from(p);
    }
    final role = prof?['profile_type']?.toString() ??
        prof?['role']?.toString() ??
        m['role']?.toString() ??
        'Deportista';
    final sport = prof?['sport']?.toString() ?? m['sport']?.toString() ?? '';
    final country = prof?['country']?.toString() ??
        m['country']?.toString() ??
        prof?['location']?.toString() ??
        '';
    final parts = [role, sport, country].where((s) => s.trim().isNotEmpty).toList();
    return parts.join(' · ');
  }

  factory PeopleListUser.fromApiMap(Map<String, dynamic> m) {
    return PeopleListUser(
      user: UserModel.fromMap(m),
      detailLine: formatDetailLine(m),
    );
  }
}

class AgeUtils {
  static int? yearsFromIsoDate(String? iso, {DateTime? now}) {
    if (iso == null || iso.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(iso.trim());
    if (parsed == null) return null;
    final today = now ?? DateTime.now();
    var years = today.year - parsed.year;
    final hadBirthday = (today.month > parsed.month) ||
        (today.month == parsed.month && today.day >= parsed.day);
    if (!hadBirthday) years -= 1;
    return years;
  }

  static bool isUnder12(String? iso, {DateTime? now}) {
    final years = yearsFromIsoDate(iso, now: now);
    return years != null && years < 12;
  }

  static bool isMinorAthlete(String? iso, String profileType, {DateTime? now}) {
    final years = yearsFromIsoDate(iso, now: now);
    return years != null &&
        years >= 12 &&
        years < 18 &&
        profileType == 'athlete';
  }
}

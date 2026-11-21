import 'package:flutter_test/flutter_test.dart';
import 'package:sport/core/utils/age_utils.dart';

void main() {
  final now = DateTime(2026, 11, 19);

  test('isUnder12 bloquea menores de 12', () {
    expect(AgeUtils.isUnder12('2015-11-20', now: now), isTrue);
    expect(AgeUtils.isUnder12('2014-11-19', now: now), isFalse);
  });

  test('isMinorAthlete solo para atletas 12-17', () {
    expect(
      AgeUtils.isMinorAthlete('2010-01-01', 'athlete', now: now),
      isTrue,
    );
    expect(
      AgeUtils.isMinorAthlete('2010-01-01', 'coach', now: now),
      isFalse,
    );
    expect(
      AgeUtils.isMinorAthlete('2000-01-01', 'athlete', now: now),
      isFalse,
    );
  });
}

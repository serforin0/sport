import 'package:flutter_test/flutter_test.dart';
import 'package:sport/features/scout_metrics/domain/entities/scout_metric.dart';

void main() {
  test('verificationLabel refleja la escalera', () {
    expect(
      const AthleteMetricValue(
        id: '1',
        definitionId: 'd',
        verificationStatus: 'self_reported',
      ).verificationLabel,
      'Autodeclarado',
    );
    expect(
      const AthleteMetricValue(
        id: '1',
        definitionId: 'd',
        verificationStatus: 'coach_verified',
      ).verificationLabel,
      'Entrenador',
    );
    expect(
      const AthleteMetricValue(
        id: '1',
        definitionId: 'd',
        verificationStatus: 'federation_verified',
      ).verificationLabel,
      'Federación',
    );
  });
}

class SportMetricDefinition {
  final String id;
  final String sportId;
  final String metricGroup;
  final String key;
  final String label;
  final String? unit;
  final bool lowerIsBetter;
  final int sortOrder;

  const SportMetricDefinition({
    required this.id,
    required this.sportId,
    required this.metricGroup,
    required this.key,
    required this.label,
    this.unit,
    this.lowerIsBetter = false,
    this.sortOrder = 0,
  });
}

class AthleteMetricValue {
  final String id;
  final String definitionId;
  final double? valueNumeric;
  final String? valueText;
  final String? recordedAt;
  final String source;
  final String verificationStatus;
  final SportMetricDefinition? definition;

  const AthleteMetricValue({
    required this.id,
    required this.definitionId,
    this.valueNumeric,
    this.valueText,
    this.recordedAt,
    this.source = 'self_reported',
    this.verificationStatus = 'self_reported',
    this.definition,
  });

  String get displayValue {
    if (valueText != null && valueText!.trim().isNotEmpty) return valueText!;
    if (valueNumeric != null) return valueNumeric!.toString();
    return '—';
  }

  String get verificationLabel => switch (verificationStatus) {
        'federation_verified' => 'Federación',
        'coach_verified' => 'Entrenador',
        _ => 'Autodeclarado',
      };
}

class ScoutMetricsSnapshot {
  final List<SportMetricDefinition> definitions;
  final List<AthleteMetricValue> values;
  final bool empty;
  final String? invite;

  const ScoutMetricsSnapshot({
    required this.definitions,
    required this.values,
    this.empty = false,
    this.invite,
  });

  Map<String, List<SportMetricDefinition>> get groupedDefinitions {
    final map = <String, List<SportMetricDefinition>>{};
    for (final def in definitions) {
      map.putIfAbsent(def.metricGroup, () => []).add(def);
    }
    return map;
  }

  AthleteMetricValue? valueFor(String definitionId) {
    for (final value in values) {
      if (value.definitionId == definitionId) return value;
    }
    return null;
  }
}

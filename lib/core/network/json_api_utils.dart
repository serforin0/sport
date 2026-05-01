/// Extrae una lista del cuerpo JSON típico de Laravel (`data` o lista raíz).
List<dynamic> unwrapDataList(dynamic body) {
  if (body is List<dynamic>) return body;
  if (body is Map) {
    final data = body['data'];
    if (data is List<dynamic>) return data;
    if (data is Map && data['data'] is List<dynamic>) {
      return data['data'] as List<dynamic>;
    }
  }
  return const [];
}

/// Extrae un mapa único de `data`.
Map<String, dynamic>? unwrapDataMap(dynamic body) {
  if (body is Map<String, dynamic>) {
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return body;
  }
  if (body is Map) {
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
  }
  return null;
}

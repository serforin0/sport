import 'package:sport/core/config/api_config.dart';

class UrlUtils {
  /// Devuelve una URL absoluta si la original es relativa (/storage/...).
  /// Si ya es una URL completa (http/https), la devuelve tal cual.
  static String? resolve(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Si ya es una URL completa (empieza por http), no tocar
    if (url.startsWith('http')) return url;
    
    // Si es una ruta relativa (empieza por /), concatenar con la base del sitio
    if (url.startsWith('/')) {
      return '$kBaseUrl$url';
    }
    
    // Otros casos: asumir que necesita la base
    return '$kBaseUrl/$url';
  }
}

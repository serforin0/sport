import 'package:flutter/material.dart';
import 'package:sport/core/theme/app_colors.dart';

enum LegalDocumentType { terms, privacy }

class LegalDocumentPage extends StatelessWidget {
  final LegalDocumentType type;

  const LegalDocumentPage({super.key, required this.type});

  String get _title => type == LegalDocumentType.terms
      ? 'Términos y condiciones'
      : 'Política de privacidad';

  String get _body {
    if (type == LegalDocumentType.terms) {
      return '''
BORRADOR — Revisar con un abogado antes de publicar.

1. Aceptación
Al crear una cuenta en HubSport aceptas estas reglas de uso de la plataforma deportiva social.

2. Cuentas y roles
Puedes registrarte como atleta, entrenador, reclutador u otros roles disponibles. Debes proporcionar información veraz.

3. Menores
La edad mínima es 12 años. Los atletas de 12 a 17 años requieren consentimiento del tutor. El tutor es responsable del uso de la cuenta del menor.

4. Conducta
No está permitido acoso, contenido ilegal, estafas o solicitud de dinero a menores. HubSport puede suspender cuentas que incumplan estas reglas.

5. Contenido
Conservas la propiedad de tu contenido. Otorgas a HubSport licencia para mostrarlo en la app según tu configuración de privacidad.

6. Suspensión
Motivos de suspensión incluyen fraude, abuso a menores, violación de privacidad o uso indebido de datos de salud.

7. Contacto
Para dudas legales usa Ayuda y soporte dentro de la app.
''';
    }

    return '''
BORRADOR — Revisar con un abogado antes de publicar.

1. Datos que tratamos
Nombre, correo, fecha de nacimiento, deporte, métricas que publiques, mensajes y reportes de seguridad.

2. Menores y tutor
Para cuentas de menores almacenamos el correo del tutor y el estado de consentimiento. Limitamos la visibilidad de datos sensibles (teléfono, club) frente a terceros.

3. Finalidad
Operar la red social deportiva, seguridad, prevención de estafas y mejora del producto.

4. Salud y wearables
Si en el futuro conectas Strava, Garmin u otras fuentes, tú decides qué datos son públicos. HubSport no venderá datos de salud.

5. Conservación y derechos
Puedes solicitar acceso o eliminación desde soporte. Conservamos auditorías de seguridad el tiempo necesario para protección de menores.

6. Contacto de privacidad
Usa Ayuda y soporte → Contactar soporte.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brand.withValues(alpha: 0.35)),
            ),
            child: const Text(
              'Documento borrador. Debe revisarse con un abogado antes de usarlo en producción.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

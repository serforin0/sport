import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/theme/app_colors.dart';
import 'package:sport/features/auth/domain/entities/user.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/onboarding/presentation/providers/onboarding_providers.dart';

class RoleGuidePage extends ConsumerWidget {
  const RoleGuidePage({super.key});

  List<_Tip> _tipsFor(String? type) {
    return switch (type) {
      'coach' => const [
          _Tip('Completa tu perfil', 'Agrega club, deporte y experiencia.'),
          _Tip('Verifica marcas', 'Ayuda a atletas elevando métricas a nivel entrenador.'),
          _Tip('Contacta con respeto', 'Los menores tienen protecciones adicionales.'),
        ],
      'recruiter' || 'sponsor' => const [
          _Tip('Revisión de cuenta', 'Tu organización queda en revisión hasta validar RNC/docs.'),
          _Tip('Publica empleos', 'Solo con insignia verificada podrás publicar oportunidades.'),
          _Tip('Busca talento', 'Usa filtros de deporte y solo verificados.'),
        ],
      'event_organizer' => const [
          _Tip('Crea eventos', 'Define tipo, cupo, ruta y calendario.'),
          _Tip('Gestiona inscritos', 'Revisa quién va y actividades vinculadas.'),
          _Tip('Moderación', 'Puedes ayudar a revisar reportes de la comunidad.'),
        ],
      _ => const [
          _Tip('Completa tu perfil scout', 'Físico, métricas y videos aumentan tu visibilidad.'),
          _Tip('Conecta', 'Acepta conexiones y escribe solo a contactos.'),
          _Tip('Postúlate', 'Revisa empleos y eventos de tu deporte.'),
        ],
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final tips = _tipsFor(user?.profileType);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guía para ${_roleLabel(user)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pasos rápidos para sacar provecho a HubSport.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: tips.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final tip = tips[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}. ${tip.title}',
                            style: const TextStyle(
                              color: AppColors.brandLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tip.body,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(onboardingActionsProvider).markRoleGuideDone();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brand,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Empezar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(User? user) {
    return switch (user?.profileType) {
      'coach' => 'entrenadores',
      'recruiter' => 'reclutadores',
      'sponsor' => 'organizaciones',
      'event_organizer' => 'organizadores',
      _ => 'atletas',
    };
  }
}

class _Tip {
  final String title;
  final String body;
  const _Tip(this.title, this.body);
}

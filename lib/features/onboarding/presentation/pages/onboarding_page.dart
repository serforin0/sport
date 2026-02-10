import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/features/onboarding/presentation/providers/onboarding_providers.dart';

import '../../../auth/presentation/pages/auth_landing_page.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const <_OnboardingModel>[
    _OnboardingModel(
      imageAsset: 'assets/onboarding/1.jpg',
      title: '¡Conéctate a través\ndel Deporte!',
      description:
          'Te conectamos con personas apasionadas por el deporte como tú. '
          'Desde entrenadores hasta analistas deportivos, aquí encontrarás la '
          'comunidad perfecta para llevar tu experiencia deportiva al siguiente nivel.',
      buttonText: 'Siguiente',
    ),
    _OnboardingModel(
      imageAsset: 'assets/onboarding/2.jpg',
      title: '¡Explora\nOportunidades!',
      description:
          'Tu pasión por el deporte se convierte en colaboración. '
          'Aquí podrás encontrar fácilmente colaboradores que compartan tu pasión '
          'por el deporte.',
      buttonText: 'Siguiente',
    ),
    _OnboardingModel(
      imageAsset: 'assets/onboarding/3.jpg',
      title: 'Descubre Eventos\nDeportivos',
      description:
          'Puedes descubrir fácilmente los eventos que están ocurriendo cerca de ti. '
          'Desde juegos de baloncesto locales hasta maratones en tu ciudad.',
      buttonText: 'Finalizar',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _nextOrFinish() async {
    final isLast = _index == _pages.length - 1;

    if (isLast) {
      await ref.read(onboardingActionsProvider).markDone();
      if (!mounted) return;

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthPage()));
      return;
    }

    await _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo por página
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) =>
                _BackgroundPage(imageAsset: _pages[i].imageAsset),
          ),

          // Botón X
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 12),
                child: _CircleIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),

          // ✅ Card inferior (compacta, como tu diseño real)
          Positioned(
            left: 16,
            right: 16,
            bottom: 48 + bottomSafe,
            child: SizedBox(
              height: size.height * 0.38, // ✅ compacta
              child: _BlurCard(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _pages[_index].title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.15,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _pages[_index].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: Colors.white.withValues(alpha: 0.90),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _Dots(current: _index, total: _pages.length),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 46,
                        width: double.infinity,
                        child: _PrimaryOutlineButton(
                          text: _pages[_index].buttonText,
                          onTap: _nextOrFinish,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingModel {
  final String imageAsset;
  final String title;
  final String description;
  final String buttonText;

  const _OnboardingModel({
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}

class _BackgroundPage extends StatelessWidget {
  final String imageAsset;
  const _BackgroundPage({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(imageAsset, fit: BoxFit.cover),
        Container(color: Colors.black.withValues(alpha: 0.15)),
      ],
    );
  }
}

class _BlurCard extends StatelessWidget {
  final Widget child;
  const _BlurCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // ✅ blur suave
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int current;
  final int total;
  const _Dots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 10 : 7,
          height: active ? 10 : 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? Colors.orangeAccent
                : Colors.white.withValues(alpha: 0.7),
          ),
        );
      }),
    );
  }
}

class _PrimaryOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PrimaryOutlineButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.85),
          width: 1.6,
        ),
        shape: const StadiumBorder(),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.25),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

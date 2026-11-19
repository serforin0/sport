import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport/core/config/api_config.dart';
import 'package:sport/core/widgets/hubsport_wordmark.dart';
import '../providers/auth_providers.dart';
import 'registration_page.dart';
import 'package:sport/core/widgets/video_background.dart';

enum AuthMode { landing, login }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({
    super.key,
    this.initialMode = AuthMode.landing,
    this.background,
    this.enableDemoLogin = kEnableDemoLogin,
  });

  final AuthMode initialMode;
  final Widget? background;
  final bool enableDemoLogin;

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  late AuthMode _mode;
  bool _obscure = true;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goLogin() => setState(() => _mode = AuthMode.login);
  void _goLanding() => setState(() => _mode = AuthMode.landing);

  @override
  Widget build(BuildContext context) {
    final bg = widget.background ?? const _DefaultBackground();
    final authState = ref.watch(authControllerProvider);

    // Listen for errors and show snackbar, and handle navigation success fallback
    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (user) {
          // No manual navigation here. main.dart handles the screen swap via state.
        },
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          bg,
          Container(color: Colors.black.withValues(alpha: 0.45)),
          if (authState.isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          SafeArea(
            // ...
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const HubSportWordmark(fontSize: 38, letterSpacing: 1.5),
                  const SizedBox(height: 24),

                  // ✅ Evita overflow en tests y pantallas pequeñas.
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, anim) {
                                return FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.04),
                                      end: Offset.zero,
                                    ).animate(anim),
                                    child: child,
                                  ),
                                );
                              },
                              child: _mode == AuthMode.login
                                  ? _LoginForm(
                                      key: const ValueKey('login'),
                                      emailCtrl: _emailCtrl,
                                      passCtrl: _passCtrl,
                                      obscure: _obscure,
                                      onToggleObscure: () =>
                                          setState(() => _obscure = !_obscure),
                                      onForgot: () {},
                                      onSubmit: () {
                                        ref
                                            .read(
                                              authControllerProvider.notifier,
                                            )
                                            .signIn(
                                              _emailCtrl.text
                                                  .trim()
                                                  .toLowerCase(),
                                              _passCtrl.text,
                                            );
                                      },
                                      onGoRegister: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegistrationPage(),
                                        ),
                                      ),
                                    )
                                  : _Landing(
                                      key: const ValueKey('landing'),
                                      onGoLogin: _goLogin,
                                      onRegisterEmail: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegistrationPage(),
                                        ),
                                      ),
                                      onDemoLogin: widget.enableDemoLogin
                                          ? () => ref
                                                .read(
                                                  authControllerProvider
                                                      .notifier,
                                                )
                                                .signInAsDemoUser()
                                          : null,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  if (_mode == AuthMode.login)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextButton(
                        onPressed: _goLanding,
                        child: const Text(
                          'Volver',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultBackground extends StatelessWidget {
  const _DefaultBackground();

  @override
  Widget build(BuildContext context) {
    return VideoBackground(assetPath: 'assets/videos/login_bg.mp4');
  }
}

class _Landing extends StatelessWidget {
  final VoidCallback onGoLogin;
  final VoidCallback onRegisterEmail;
  final VoidCallback? onDemoLogin;

  const _Landing({
    super.key,
    required this.onGoLogin,
    required this.onRegisterEmail,
    this.onDemoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrimaryButton(
            text: 'ENTRAR',
            backgroundColor: const Color(0xFF1E3A8A),
            onTap: onGoLogin,
          ),
          const SizedBox(height: 16),
          _PrimaryButton(
            text: 'REGISTRARSE',
            backgroundColor: const Color(0xFF3B82F6),
            onTap: onRegisterEmail,
          ),
          if (onDemoLogin != null) ...[
            const SizedBox(height: 12),
            _PrimaryButton(
              text: 'USUARIO DE PRUEBA',
              backgroundColor: const Color(0xFF0F766E),
              onTap: onDemoLogin!,
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;

  final VoidCallback onForgot;
  final VoidCallback onSubmit;
  final VoidCallback onGoRegister;

  const _LoginForm({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.onForgot,
    required this.onSubmit,
    required this.onGoRegister,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ NO Spacer/Expanded dentro de ScrollView.
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Correo electrónico'),
          const SizedBox(height: 6),
          _PillTextField(
            controller: emailCtrl,
            hint: 'Ingresa tu correo',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 14),

          const _FieldLabel('Contraseña'),
          const SizedBox(height: 6),
          _PillTextField(
            controller: passCtrl,
            hint: 'Ingresa tu contraseña',
            obscure: obscure,
            suffix: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgot,
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ),
          ),

          const SizedBox(height: 10),

          _PrimaryButton(text: 'Iniciar sesión', onTap: onSubmit),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes una cuenta? ',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
              GestureDetector(
                onTap: onGoRegister,
                child: const Text(
                  'Regístrate ahora',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.95),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;

  const _PillTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Colors.blue.withValues(alpha: 0.75),
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}


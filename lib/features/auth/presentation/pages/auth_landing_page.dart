import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import 'registration_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

enum AuthMode { landing, login }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({
    super.key,
    this.initialMode = AuthMode.landing,
    this.background,
  });

  final AuthMode initialMode;
  final Widget? background;

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
    final bg = widget.background ?? _DefaultBackground();
    final authState = ref.watch(authControllerProvider);

    // Listen for errors and show snackbar
    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err.toString())),
          );
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
                  const Text(
                    'HUBSPORT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
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
                                      onForgot: () {},
                                      onSubmit: () {
                                        ref
                                            .read(authControllerProvider.notifier)
                                            .signIn(_emailCtrl.text, _passCtrl.text);
                                      },
                                      onSocialGoogle: () {},
                                      onSocialFacebook: () {},
                                      onSocialApple: () {},
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
                                              ProfilePage(), // TEMPORAL: Navega a Perfil para ver avances
                                        ),
                                      ),
                                      onGoogle: () {},
                                      onFacebook: () {},
                                      onApple: () {},
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
  @override
  Widget build(BuildContext context) {
    return const VideoBackground(assetPath: 'assets/auth/login_bg.mp4');
  }
}

class _Landing extends StatelessWidget {
  final VoidCallback onGoLogin;
  final VoidCallback onRegisterEmail;
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;
  final VoidCallback onApple;

  const _Landing({
    super.key,
    required this.onGoLogin,
    required this.onRegisterEmail,
    required this.onGoogle,
    required this.onFacebook,
    required this.onApple,
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
            backgroundColor: const Color(0xFF1E3A8A), // Azul oscuro
            onTap: onGoLogin,
          ),
          const SizedBox(height: 16),
          _PrimaryButton(
            text: 'REGISTRARSE',
            backgroundColor: const Color(0xFF3B82F6), // Azul claro
            onTap: onRegisterEmail,
          ),
          const SizedBox(height: 32),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'o continúa con',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIconButton(text: 'G', onTap: onGoogle),
              const SizedBox(width: 16),
              _SocialIconButton(text: 'f', onTap: onFacebook),
              const SizedBox(width: 16),
              _SocialIconButton(text: '', onTap: onApple),
            ],
          ),
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

  final VoidCallback onSocialGoogle;
  final VoidCallback onSocialFacebook;
  final VoidCallback onSocialApple;

  final VoidCallback onGoRegister;

  const _LoginForm({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.onForgot,
    required this.onSubmit,
    required this.onSocialGoogle,
    required this.onSocialFacebook,
    required this.onSocialApple,
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

          const SizedBox(height: 16),

          Center(
            child: Text(
              'Inicia sesión con',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIconButton(text: 'G', onTap: onSocialGoogle),
              const SizedBox(width: 14),
              _SocialIconButton(text: 'f', onTap: onSocialFacebook),
              const SizedBox(width: 14),
              _SocialIconButton(text: '', onTap: onSocialApple),
            ],
          ),

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
          backgroundColor: backgroundColor ?? Colors.blue.withValues(alpha: 0.75),
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

class _OutlineSocialButton extends StatelessWidget {
  final String text;
  final String iconText;
  final VoidCallback onTap;

  const _OutlineSocialButton({
    required this.text,
    required this.iconText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              iconText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SocialIconButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

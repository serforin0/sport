import 'package:flutter/material.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/social_auth_button.dart';
import 'registration_page.dart';
import 'login_page.dart';


class LoginMethodPage extends StatelessWidget {
  const LoginMethodPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A43),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(
                child: Text(
                  'HUBSPORT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Regístrate por correo',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrationPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes una cuenta?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('o', style: TextStyle(color: Colors.white54)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 24),
              SocialAuthButton(
                text: 'Regístrate con Google',
                icon: Icons.g_mobiledata, // Placeholder
                backgroundColor: Colors.white,
                textColor: Colors.black87,
                iconColor: Colors.black87,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              SocialAuthButton(
                text: 'Regístrate con Facebook',
                icon: Icons.facebook,
                backgroundColor: const Color(0xFF1877F2),
                textColor: Colors.white,
                iconColor: Colors.white,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              SocialAuthButton(
                text: 'Regístrate con Apple',
                icon: Icons.apple,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                iconColor: Colors.white,
                onPressed: () {},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

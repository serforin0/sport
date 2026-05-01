import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu correo')),
      );
      return;
    }

    final success = await ref.read(forgotPasswordNotifierProvider.notifier).sendCode(email);
    
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(email: email),
        ),
      );
    } else if (mounted) {
      final error = ref.read(forgotPasswordNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? 'Error al enviar el código')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(forgotPasswordNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Recuperar contraseña', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ingresa tu correo electrónico y te enviaremos un código para recuperar el acceso a tu cuenta.',
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              CustomTextField(
                controller: _emailController,
                hintText: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: isLoading ? 'Enviando...' : 'Enviar código',
                onPressed: () { _handleSendCode(); },
                isLoading: isLoading,
              ),


            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;
  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _codeController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final code = _codeController.text.trim();
    final password = _passController.text;
    final confirm = _confirmPassController.text;

    if (code.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    final success = await ref.read(forgotPasswordNotifierProvider.notifier).resetPassword(
          email: widget.email,
          code: code,
          password: password,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada con éxito')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      final error = ref.read(forgotPasswordNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? 'Error al restablecer contraseña')),
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
        title: const Text('Nueva Contraseña', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hemos enviado un código a ${widget.email}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _codeController,
                hintText: 'Código de 6 dígitos',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.lock_clock_outlined, color: Colors.white54),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _passController,
                hintText: 'Nueva contraseña',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
              ),

              const SizedBox(height: 20),
              CustomTextField(
                controller: _confirmPassController,
                hintText: 'Confirmar contraseña',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
              ),

              const SizedBox(height: 40),
              PrimaryButton(
                text: isLoading ? 'Procesando...' : 'RESTABLECER CONTRASEÑA',
                onPressed: () { _handleReset(); },
                isLoading: isLoading,
              ),



            ],
          ),
        ),
      ),
    );
  }
}

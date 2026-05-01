import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A43),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Registro de usuario', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CustomTextField(
                hintText: 'Nombres',
                prefixIcon: Icon(Icons.person_outline, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                hintText: 'Apellidos',
                prefixIcon: Icon(Icons.person_outline, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                hintText: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                hintText: 'Contraseña',
                isPassword: true,
                prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              const CustomTextField(
                hintText: 'Confirmar contraseña',
                isPassword: true,
                prefixIcon: Icon(Icons.lock_outline, color: Colors.white54),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Registrarme',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

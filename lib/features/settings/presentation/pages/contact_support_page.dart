import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import 'package:sport/core/providers/shared_preferences_provider.dart';
import 'package:sport/features/auth/presentation/providers/auth_providers.dart';
import 'package:sport/features/support/presentation/providers/support_providers.dart';

class ContactSupportPage extends ConsumerStatefulWidget {
  const ContactSupportPage({super.key});

  @override
  ConsumerState<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends ConsumerState<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedReason = 'Problema/error en la app';
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).valueOrNull;
      if (user != null && user.email.isNotEmpty) {
        _emailController.text = user.email;
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final token = prefs.getString('auth_token');
    final needsEmail = token == null;
    if (needsEmail && _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indica tu correo para contactarte')),
      );
      return;
    }

    try {
      await ref.read(supportRemoteDataSourceProvider).submitContact(
            token: token,
            subject: _selectedReason,
            message: _messageController.text.trim(),
            email: needsEmail ? _emailController.text.trim() : null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mensaje enviado con éxito')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = ref.watch(sharedPreferencesProvider).getString('auth_token');
    final showEmailField = token == null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CONTACTA CON HUBSPORT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Motivo de contacto',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedReason,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
                    items: [
                      'Problema/error en la app',
                      'Sugerencia y mejoras',
                      'Problema con mi cuenta',
                      'Otros',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedReason = newValue!;
                      });
                    },
                  ),
                ),
              ),
              if (showEmailField) ...[
                const SizedBox(height: 24),
                const Text(
                  'Correo electrónico',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  validator: Validators.validateEmail,
                  decoration: InputDecoration(
                    hintText: 'tu@email.com',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Le estaremos contactando vía correo. Nuestro tiempo de respuesta es de 24hrs.',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
              const SizedBox(height: 32),
              const Text(
                'Mensaje',
                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                validator: Validators.validateMessage,
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje aquí...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6).withOpacity(0.2),
                    foregroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Enviar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

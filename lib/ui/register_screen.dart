import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para capturar los datos del estudiante
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Botón para volver al Login
      appBar: AppBar(
        title: const Text('Registro MetroSwap'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.person_add_alt_1_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Crea tu cuenta UNIMET',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // Campo de Correo
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Institucional (@unimet.edu.ve)',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña (mín. 6 caracteres)',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),

              // Botón de Registro
              FilledButton(
                onPressed: () async {
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();
                  

                  // Llamamos al servicio para registrar en Firebase
                  String? error = await _authService.registrarEstudiante(email, password);

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Cuenta creada con éxito! Ya puedes iniciar sesión."),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Volver al Login automáticamente
                    Navigator.pop(context);
                  }
                },
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
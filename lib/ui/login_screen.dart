import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart'; // Importante para la navegación

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      body: Stack(
        children: [
          // 1. Imagen de fondo del campus abarcando toda la pantalla
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo_campus.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. Capa semitransparente azul oscura para darle legibilidad al cuadro
          Container(color: const Color(0xFF002B49).withOpacity(0.85)),
          // 3. El cuadro de Login centrado
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ), // Ancho de la tarjeta
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo de MetroSwap
                        Image.asset(
                          'assets/images/logo_metroswap.png',
                          height:
                              80, // Puedes subirle a 100 si lo ves muy pequeño
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Bienvenido a MetroSwap',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002B49),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Inicia sesión con tu correo institucional',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),

                        // --- AQUÍ EMPIEZA TU CÓDIGO ORIGINAL INTACTO ---
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo Institucional (@unimet.edu.ve)',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () async {
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();

                            String? error = await _authService.iniciarSesion(
                              email,
                              password,
                            );
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "¡Bienvenido Estudiante! Acceso concedido.",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            '¿No tienes cuenta? Regístrate aquí',
                          ),
                        ),
                        // --- FIN DE TU CÓDIGO ORIGINAL ---
                      ],
                    ),
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

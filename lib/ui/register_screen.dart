import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  // VARIABLES QUE NO PARPADEAN
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Registro MetroSwap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondo_campus.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: const Color(0xFF002855).withOpacity(0.85)),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset('assets/images/logo_metroswap.png', height: 80),
                        const SizedBox(height: 24),
                        const Text(
                          'Crea tu cuenta',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF002855)),
                        ),
                        const SizedBox(height: 32),

                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            label: Text.rich(TextSpan(children: [TextSpan(text: 'Correo Institucional (@unimet.edu.ve)'), TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // CONTRASEÑA 1
                        ValueListenableBuilder<bool>(
                          valueListenable: _obscurePassword,
                          builder: (context, isObscure, child) {
                            return TextField(
                              controller: _passwordController,
                              obscureText: isObscure,
                              decoration: InputDecoration(
                                label: const Text.rich(TextSpan(children: [TextSpan(text: 'Contraseña (mín. 6 caracteres)'), TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => _obscurePassword.value = !isObscure,
                                ),
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: 16),

                        // CONTRASEÑA 2
                        ValueListenableBuilder<bool>(
                          valueListenable: _obscureConfirmPassword,
                          builder: (context, isObscure, child) {
                            return TextField(
                              controller: _confirmPasswordController,
                              obscureText: isObscure,
                              decoration: InputDecoration(
                                label: const Text.rich(TextSpan(children: [TextSpan(text: 'Confirmar Contraseña'), TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => _obscureConfirmPassword.value = !isObscure,
                                ),
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: 32),

                        FilledButton(
                          onPressed: () async {
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();
                            String confirmPassword = _confirmPasswordController.text.trim();

                            if (password != confirmPassword) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las contraseñas no coinciden.'), backgroundColor: Colors.red));
                              }
                              return;
                            }

                            String? error = await _authService.registrarEstudiante(email, password);

                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Cuenta creada con éxito! Ya puedes iniciar sesión."), backgroundColor: Colors.green));
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
            ),
          ),
        ],
      ),
    );
  }
}
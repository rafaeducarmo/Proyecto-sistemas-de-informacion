import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  
  // Controladores para el Perfil
  final _nameController = TextEditingController();
  String _selectedCareer = 'Ingeniería de Sistemas';

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _showPasswordFields = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CONTRASEÑA (La que ya tenías) ---
  Future<void> _cambiarContrasena() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? error = await _authService.cambiarContrasena(oldPassword, newPassword);
    setState(() => _isLoading = false);

    if (error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Contraseña actualizada exitosamente!"), backgroundColor: Colors.green),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
      FocusScope.of(context).unfocus();
      setState(() => _showPasswordFields = false);
    }
  }

  // --- NUEVA LÓGICA DE PERFIL ---
  Future<void> _guardarPerfil(User user) async {
    try {
      // Guarda los datos en la colección 'users'
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': _nameController.text.trim(),
        'email': user.email,
        'career': _selectedCareer,
        'profilePic': '', // Por ahora vacío
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Perfil actualizado con éxito!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Cierra el modal
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _mostrarDialogoEdicion(User user, Map<String, dynamic>? currentData) {
    // Si ya tiene datos, los cargamos en los campos
    if (currentData != null) {
      _nameController.text = currentData['name'] ?? '';
      _selectedCareer = ['Ingeniería de Sistemas', 'Ingeniería Civil', 'Derecho', 'Administración', 'Psicología', 'Otra']
              .contains(currentData['career']) ? currentData['career'] : 'Ingeniería de Sistemas';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCareer,
              decoration: const InputDecoration(labelText: 'Carrera', border: OutlineInputBorder()),
              items: ['Ingeniería de Sistemas', 'Ingeniería Civil', 'Derecho', 'Administración', 'Psicología', 'Otra']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedCareer = val!),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(onPressed: () => _guardarPerfil(user), child: const Text('Guardar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Error: No hay usuario activo'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.orange),
            const SizedBox(height: 16),
            
            // --- STREAMBUILDER PARA LEER LOS DATOS EN TIEMPO REAL ---
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Extraemos los datos si existen
                final userData = snapshot.data?.data() as Map<String, dynamic>?;
                final nombre = userData?['name'] ?? 'Estudiante UNIMET';
                final carrera = userData?['career'] ?? 'Carrera no especificada';

                return Column(
                  children: [
                    Text(
                      nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Carrera: $carrera', 
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Correo: ${user.email}', 
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // AQUÍ ESTÁ EL BOTÓN DE EDITAR CORREGIDO
                    OutlinedButton.icon(
                      onPressed: () => _mostrarDialogoEdicion(user, userData),
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text('Editar Perfil', style: TextStyle(color: Colors.blue)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ],
                );
              },
            ),
            // --------------------------------------------------------

            const SizedBox(height: 48),

            // SECCIÓN DE CAMBIO DE CONTRASEÑA
            if (!_showPasswordFields)
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _showPasswordFields = true;
                  });
                },
                icon: const Icon(Icons.lock_reset),
                label: const Text('Cambiar Contraseña'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueGrey,
                ),
              )
            else ...[
              const Text(
                'Cambiar Contraseña',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña Actual',
                  prefixIcon: Icon(Icons.lock_clock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nueva Contraseña',
                  prefixIcon: Icon(Icons.lock_reset),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _showPasswordFields = false;
                                _oldPasswordController.clear();
                                _newPasswordController.clear();
                              });
                            },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _cambiarContrasena,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Actualizar', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
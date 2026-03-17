import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../Models/book_model.dart';
import 'admin_screen.dart'; 

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Controladores para la Contraseña
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  // Controladores para el Perfil
  final _nameController = TextEditingController();
  String _selectedCareer = 'Ingeniería de Sistemas';

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _showPasswordFields = false;

  // --- VARIABLES PARA LOS OJITOS (ValueNotifier para no recargar la pantalla) ---
  final ValueNotifier<bool> _obscureOldPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureNewPassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _nameController.dispose();
    
    // Limpiamos los Notifiers de la memoria
    _obscureOldPassword.dispose();
    _obscureNewPassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CONTRASEÑA ---
  Future<void> _cambiarContrasena() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos'), backgroundColor: Colors.red),
      );
      return;
    }

    if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas nuevas no coinciden'), backgroundColor: Colors.red),
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
      _confirmNewPasswordController.clear();
      FocusScope.of(context).unfocus();
      setState(() {
        _showPasswordFields = false;
        // Reiniciamos los ojitos
        _obscureOldPassword.value = true;
        _obscureNewPassword.value = true;
        _obscureConfirmPassword.value = true;
      });
    }
  }

  // --- LÓGICA DE PERFIL ---
  Future<void> _guardarPerfil(User user) async {
    try {
      // Usamos SetOptions(merge: true) para no borrar el rol de admin si lo tiene
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': _nameController.text.trim(),
        'email': user.email,
        'career': _selectedCareer,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Perfil actualizado con éxito!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- LÓGICA DE ELIMINACIÓN DE LIBRO ---
  Future<void> _confirmarEliminacionLibro(String bookId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar libro'),
        content: const Text('¿Estás seguro de que deseas eliminar este libro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      try {
        await BookService().deleteBook(bookId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Libro eliminado con éxito'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _mostrarDialogoEdicion(User user, Map<String, dynamic>? currentData) {
    if (currentData != null) {
      _nameController.text = currentData['name'] ?? '';
      _selectedCareer = [
        'Ingeniería de Sistemas', 'Ingeniería Civil', 'Derecho', 'Administración', 'Psicología', 'Otra'
      ].contains(currentData['career']) ? currentData['career'] : 'Ingeniería de Sistemas';
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
              items: [
                'Ingeniería de Sistemas', 'Ingeniería Civil', 'Derecho', 'Administración', 'Psicología', 'Otra'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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

  void _mostrarDialogoDonacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Donaciones MetroSwap',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu aporte ayuda a mejorar los recursos de la biblioteca.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              '📱 Pago Móvil:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF002855)),
            ),
            SizedBox(height: 4),
            Text('Banco Mercantil (0105)\nTeléfono: 0412-1234567\nRIF: V-12345678'),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text(
              '💻 PayPal:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF002855)),
            ),
            SizedBox(height: 4),
            Text('donacionesunimet@gmail.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
          ),
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
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Mi Perfil',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF002855), letterSpacing: -0.5),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset('assets/images/logo_unimet.png', height: 35),
          ),
        ],
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

                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final userData = snapshot.data?.data() as Map<String, dynamic>?;
                    final nombre = userData?['name'] ?? 'Estudiante UNIMET';
                    final carrera = userData?['career'] ?? 'Carrera no especificada';
                    
                    final role = userData?['role'] ?? 'student';
                    final isAdmin = (user.email == 'admin@unimet.edu.ve' || role == 'admin');

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
                        OutlinedButton.icon(
                          onPressed: () => _mostrarDialogoEdicion(user, userData),
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          label: const Text('Editar Perfil', style: TextStyle(color: Colors.blue)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
                        ),
                        
                        if (isAdmin) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AdminScreen()),
                              );
                            },
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Panel de Administración'),
                            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoDonacion(context),
                    icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                    label: const Text('Apoyar a la Biblioteca', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D4037),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
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
                  
                  // CONTRASEÑA ACTUAL CON OJITO
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscureOldPassword,
                    builder: (context, isObscure, child) {
                      return TextField(
                        controller: _oldPasswordController,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          label: const Text.rich(TextSpan(children: [TextSpan(text: 'Contraseña Actual'), TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
                          prefixIcon: const Icon(Icons.lock_clock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => _obscureOldPassword.value = !isObscure,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // NUEVA CONTRASEÑA CON OJITO
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscureNewPassword,
                    builder: (context, isObscure, child) {
                      return TextField(
                        controller: _newPasswordController,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          label: const Text.rich(TextSpan(children: [TextSpan(text: 'Nueva Contraseña'), TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
                          prefixIcon: const Icon(Icons.lock_reset),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => _obscureNewPassword.value = !isObscure,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // CONFIRMAR CONTRASEÑA CON OJITO
                  ValueListenableBuilder<bool>(
                    valueListenable: _obscureConfirmPassword,
                    builder: (context, isObscure, child) {
                      return TextField(
                        controller: _confirmNewPasswordController,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          label: const Text.rich(TextSpan(children: [TextSpan(text: 'Confirmar Nueva Contraseña'), TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
                          prefixIcon: const Icon(Icons.lock_reset),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => _obscureConfirmPassword.value = !isObscure,
                          ),
                        ),
                      );
                    },
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
                                    _confirmNewPasswordController.clear();
                                    // Reiniciamos los ojitos
                                    _obscureOldPassword.value = true;
                                    _obscureNewPassword.value = true;
                                    _obscureConfirmPassword.value = true;
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

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                const Text(
                  'Mis Libros Publicados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Book>>(
                  stream: BookService().getUserBooksStream(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error al cargar libros.'));
                    }
                    final books = snapshot.data ?? [];
                    if (books.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Aún no has publicado ningún libro.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            leading: book.imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      book.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.book, size: 40),
                                    ),
                                  )
                                : const Icon(Icons.book, size: 40),
                            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${book.condition} • ${book.status}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarEliminacionLibro(book.id),
                              tooltip: 'Eliminar libro',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                OutlinedButton.icon(
                  onPressed: () async {
                    // Cierra sesión sin Navigator. El main.dart se encarga de redirigir.
                    await FirebaseAuth.instance.signOut();
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
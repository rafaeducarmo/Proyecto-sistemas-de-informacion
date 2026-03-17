import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  // Función para borrar un libro
  void _borrarLibro(BuildContext context, String bookId) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material eliminado del sistema'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Administración', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.book), text: 'Todos los Materiales'),
              Tab(icon: Icon(Icons.people), text: 'Usuarios Registrados'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // PESTAÑA 1: GESTIÓN DE LIBROS
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('books').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No hay libros en el sistema.'));

                final books = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index].data() as Map<String, dynamic>;
                    final bookId = books[index].id;
                    // AQUÍ ESTÁ LA LÍNEA QUE FALTABA:
                    final bookIdPropietario = book['ownerId'] ?? ''; 

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(book['imageUrl'] ?? ''),
                        onBackgroundImageError: (_, __) => const Icon(Icons.broken_image),
                      ),
                      title: Text(book['title'] ?? 'Sin título', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(bookIdPropietario).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Cargando dueño...');
                          }
                          if (userSnapshot.hasData && userSnapshot.data!.exists) {
                            final ownerData = userSnapshot.data!.data() as Map<String, dynamic>;
                            return Text('Propietario: ${ownerData['name']} \n(ID: $bookIdPropietario)');
                          }
                          return const Text('Propietario desconocido');
                        },
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _borrarLibro(context, bookId),
                      ),
                    );
                  },
                );
              },
            ),

            // PESTAÑA 2: GESTIÓN DE USUARIOS
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No hay perfiles guardados.'));

                final users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.account_circle, size: 40, color: Colors.blueGrey),
                      title: Text(user['name'] ?? 'Sin nombre'),
                      subtitle: Text('${user['email']} \nCarrera: ${user['career']}'),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
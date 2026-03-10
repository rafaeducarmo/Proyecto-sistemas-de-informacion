import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_book_screen.dart';
import '../services/book_service.dart';
import '../Models/book_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciamos tu servicio para acceder al Stream
    final bookService = BookService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo MetroSwap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      // El StreamBuilder escucha tu base de datos en tiempo real
      body: StreamBuilder<List<Book>>(
        stream: bookService.getBooksStream(),
        builder: (context, snapshot) {
          // 1. Mientras carga la información de internet
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Si ocurre un error en la descarga
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar catálogo: ${snapshot.error}'),
            );
          }
          // 3. Si la base de datos está vacía
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay materiales publicados aún.\n¡Sé el primero en compartir!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // 4. Si hay datos, armamos el catálogo
          final books = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Dos libros por fila
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65, // Ajusta la altura de las tarjetas
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto del libro
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          book.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // Si el link de la foto falla, mostramos un ícono roto
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                    // Detalles del libro
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            book.category,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book.condition,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../Models/book_model.dart';
import 'book_detail_screen.dart'; // <--- ESTA ES LA QUE FALTA

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  final List<String> _categories = ['Todas', 'Ingeniería', 'Salud', 'Artes', 'Ciencias', 'Otros'];
  String _quitarAcentos(String texto) {
    const conAcento = 'áéíóúÁÉÍÓÚñÑüÜ';
    const sinAcento = 'aeiouAEIOUnNuU';
    String res = texto;
    for (int i = 0; i < conAcento.length; i++) {
      res = res.replaceAll(conAcento[i], sinAcento[i]);
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo MetroSwap'),
      ),
      body: Column(
        children: [
          // 1. LA BARRA DE BÚSQUEDA Y FILTROS
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar título o autor...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      items: _categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. EL CATÁLOGO DE LIBROS
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: _bookService.getBooksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay materiales publicados aún.\n¡Ve a "Publicar" y sé el primero!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final books = snapshot.data!.where((book) {
                  // Limpiamos los textos quitando acentos y mayúsculas
                  final busquedaLimpia = _quitarAcentos(_searchQuery.toLowerCase());
                  final tituloLimpio = _quitarAcentos(book.title.toLowerCase());
                  final descLimpia = _quitarAcentos(book.description.toLowerCase());

                  final matchesSearch = tituloLimpio.contains(busquedaLimpia) || 
                                        descLimpia.contains(busquedaLimpia);
                  final matchesCategory = _selectedCategory == 'Todas' || book.category == _selectedCategory;
                  
                  return matchesSearch && matchesCategory;
                }).toList();
                if (books.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron libros con esos filtros.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    
                    // --- AQUÍ ESTÁ LA MAGIA DEL CLIC ---
                    return GestureDetector(
                      onTap: () {
                        // Navega a la pantalla de detalles usando el Navigator
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  book.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                                ),
                              ),
                            ),
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
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
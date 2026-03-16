import 'dart:typed_data'; // <-- Para la memoria
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/book_provider.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Seleccionar...';
  String _selectedCondition = 'Nuevo';
  
  Uint8List? _imageBytes; // <-- Guardamos la foto en bytes
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      // Leemos los bytes para que funcione en Web
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _imageBytes != null) {
      final provider = Provider.of<BookProvider>(context, listen: false);

      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'usuario_desconocido';

      bool success = await provider.uploadBook(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        condition: _selectedCondition,
        imageBytes: _imageBytes!, // <-- Pasamos los bytes
        ownerId: currentUserId,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Material publicado con éxito en MetroSwap!'), backgroundColor: Colors.green,),
        );
        // Regresamos a la pestaña de inicio modificando el índice o haciendo pop según lo necesites
        // Como estamos en un BottomNavigationBar, lo mejor es limpiar el form
        setState(() {
          _titleController.clear();
          _descriptionController.clear();
          _imageBytes = null;
          _selectedCategory = 'Seleccionar...';
          _selectedCondition = 'Nuevo';
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al publicar el material. Revisa tu conexión.'), backgroundColor: Colors.red,),
        );
      }
    } else if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una foto del material.'), backgroundColor: Colors.orange,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<BookProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 20.0),
         child: Text(
          'Publicar Material',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF5D4037),
            letterSpacing: -0.5,
          ),
          ),
        ),
        centerTitle: false,
        ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400)
                        ),
                        // Usamos Image.memory en lugar de Image.file
                        child: _imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text("Toca para subir una foto", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        label: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Título del libro o material'),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        label: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Descripción / Autor / Detalles'),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        label: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Categoría'),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Seleccionar...', 'Ingeniería', 'Salud', 'Artes', 'Ciencias', 'Otros'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      validator: (val) => val == 'Seleccionar...' ? 'Requerido: Elija una categoría válida' : null,
                      onChanged: (val) => setState(() => _selectedCategory = val.toString()),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField(
                      value: _selectedCondition,
                      decoration: const InputDecoration(
                        label: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Condición'),
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Nuevo', 'Como Nuevo', 'Buen estado', 'Deteriorado'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setState(() => _selectedCondition = val.toString()),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _submitForm,
                        child: const Text('Publicar Material', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/book_model.dart';
import '../Models/exchange_model.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  // Función para guardar el intercambio en Firebase
  void _solicitarIntercambio(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (book.ownerId == currentUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este es tu propio material.'), backgroundColor: Colors.orange),
      );
      return;
    }

    // --- NUEVO: PEDIR FECHAS CON DIÁLOGO PERSONALIZADO ---
    final DateTimeRange? pickedRange = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) {
        DateTime? start;
        DateTime? end;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Período de solicitud'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona las fechas en las que necesitas el material:', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(text: start != null ? "${start!.day}/${start!.month}/${start!.year}" : ''),
                    decoration: const InputDecoration(
                      labelText: 'Fecha de inicio',
                      hintText: 'Seleccionar...',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: start ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          start = picked;
                          if (end != null && end!.isBefore(start!)) end = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(text: end != null ? "${end!.day}/${end!.month}/${end!.year}" : ''),
                    decoration: const InputDecoration(
                      labelText: 'Fecha final',
                      hintText: 'Seleccionar...',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: end ?? (start ?? DateTime.now()),
                        firstDate: start ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => end = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                FilledButton(
                  onPressed: (start != null && end != null) 
                    ? () => Navigator.pop(context, DateTimeRange(start: start!, end: end!))
                    : null,
                  child: const Text('Confirmar Fechas'),
                ),
              ],
            );
          },
        );
      },
    );

    // Si el usuario canceló el calendario, no seguimos con la solicitud
    if (pickedRange == null) return;

    try {
      String exchangeId = DateTime.now().millisecondsSinceEpoch.toString();
      
      Exchange newExchange = Exchange(
        id: exchangeId,
        bookId: book.id,
        requesterId: currentUser.uid,
        ownerId: book.ownerId,
        status: 'Pendiente',
        requestDate: DateTime.now(),
        startDate: pickedRange.start, // <-- Guardamos la fecha de inicio
        endDate: pickedRange.end,     // <-- Guardamos la fecha de fin
      );

      await FirebaseFirestore.instance
          .collection('exchanges')
          .doc(exchangeId)
          .set(newExchange.toMap());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Solicitud de intercambio enviada al dueño!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al solicitar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del Material')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                book.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 300,
                  child: Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(book.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(label: Text(book.category)),
                const SizedBox(width: 8),
                Chip(
                  label: Text(book.condition, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Descripción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(book.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () => _solicitarIntercambio(context),
                icon: const Icon(Icons.handshake),
                label: const Text('Solicitar Intercambio', style: TextStyle(fontSize: 18)),
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
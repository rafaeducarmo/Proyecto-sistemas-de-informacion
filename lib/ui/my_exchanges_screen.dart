import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/exchange_service.dart';
import '../Models/exchange_model.dart';

class MyExchangesScreen extends StatefulWidget {
  const MyExchangesScreen({super.key});

  @override
  State<MyExchangesScreen> createState() => _MyExchangesScreenState();
}

class _MyExchangesScreenState extends State<MyExchangesScreen> {
  final ExchangeService _exchangeService = ExchangeService();
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Actualizamos la función para saber si estamos en la pestaña de "Mis Solicitudes"
  Widget _buildExchangeList(Stream<List<Exchange>> stream, String emptyMessage, bool isMisSolicitudes) {
    return StreamBuilder<List<Exchange>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)));
        }

        final exchanges = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: exchanges.length,
          itemBuilder: (context, index) {
            final exchange = exchanges[index];
            // En vez de un Card simple, llamamos a nuestro nuevo Widget personalizado
            return ExchangeTile(exchange: exchange, isMisSolicitudes: isMisSolicitudes);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: const Text(
              'Mis Intercambios',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF5D4037),
                letterSpacing: -0.5,
              ),
            ),
          ),
          centerTitle: false,

          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mis Solicitudes (Quiero)'),
              Tab(text: 'Recibidas (Me piden)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña 1: Lo que yo pido (Soy el requester)
            _buildExchangeList(
              _exchangeService.getMisSolicitudes(currentUserId),
              'No has solicitado ningún material todavía.',
              true, // isMisSolicitudes = true
            ),
            // Pestaña 2: Lo que me piden a mí (Soy el owner)
            _buildExchangeList(
              _exchangeService.getSolicitudesRecibidas(currentUserId),
              'Nadie ha solicitado tus materiales todavía.',
              false, // isMisSolicitudes = false
            ),
          ],
        ),
      ),
    );
  }
}

// --- NUEVO WIDGET PARA CARGAR LOS DATOS REALES ---
class ExchangeTile extends StatelessWidget {
  final Exchange exchange;
  final bool isMisSolicitudes;

  const ExchangeTile({super.key, required this.exchange, required this.isMisSolicitudes});

  @override
  Widget build(BuildContext context) {
    // Si es mi solicitud, busco al dueño. Si la recibí, busco al que me la pide.
    final otherUserId = isMisSolicitudes ? exchange.ownerId : exchange.requesterId;

    return FutureBuilder(
      // Usamos Future.wait para ir a buscar el Libro y el Usuario al mismo tiempo
      future: Future.wait([
        FirebaseFirestore.instance.collection('books').doc(exchange.bookId).get(),
        FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      ]),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Cargando información...'),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Si algo falla, no mostramos nada roto
        }

        // Extraemos la información de los documentos
        final bookDoc = snapshot.data![0];
        final userDoc = snapshot.data![1];

        final bookData = bookDoc.data() as Map<String, dynamic>?;
        final userData = userDoc.data() as Map<String, dynamic>?;

        final bookTitle = bookData?['title'] ?? 'Material eliminado';
        final bookImage = bookData?['imageUrl'] ?? '';
        final otherUserName = userData?['name'] ?? 'Estudiante desconocido';

        // Etiqueta dinámica dependiendo de la pestaña
        final userLabel = isMisSolicitudes 
            ? 'Se lo pides a: $otherUserName' 
            : 'Te lo pide: $otherUserName';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: bookImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(bookImage, width: 50, height: 70, fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),),
                  )
                : const Icon(Icons.book, size: 40, color: Colors.orange),
            title: Text(bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$userLabel\nEstado: ${exchange.status}'),
            isThreeLine: true,
            trailing: Chip(
              label: Text(exchange.status),
              backgroundColor: exchange.status == 'Pendiente' ? Colors.orange.shade100 : Colors.green.shade100,
            ),
            
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Detalles del Intercambio'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Material: $bookTitle', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(userLabel),
                      const SizedBox(height: 8),
                      Text('Estado actual: ${exchange.status}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                    // Botón de Aceptar solo si eres el dueño y está pendiente
                    if (!isMisSolicitudes && exchange.status == 'Pendiente')
                      FilledButton(
                        onPressed: () async {
                          // Actualizamos la base de datos a Aceptado
                          await FirebaseFirestore.instance
                              .collection('exchanges')
                              .doc(exchange.id)
                              .update({'status': 'Aceptado'});
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('¡Intercambio aceptado!'), backgroundColor: Colors.green),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Aceptar Solicitud'),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
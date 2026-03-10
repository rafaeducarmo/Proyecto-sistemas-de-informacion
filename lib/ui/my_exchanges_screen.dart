import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Un widget reutilizable para mostrar las listas de intercambios
  Widget _buildExchangeList(Stream<List<Exchange>> stream, String emptyMessage) {
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
            return Card(
              child: ListTile(
                leading: const Icon(Icons.handshake, color: Colors.orange),
                title: Text('ID del Libro: ${exchange.bookId}'),
                subtitle: Text('Estado: ${exchange.status}'),
                trailing: Chip(
                  label: Text(exchange.status),
                  backgroundColor: exchange.status == 'Pendiente' ? Colors.orange.shade100 : Colors.green.shade100,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Dos pestañas
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Intercambios'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Mis Solicitudes (Quiero)'),
              Tab(text: 'Recibidas (Me piden)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña 1: Lo que yo pido
            _buildExchangeList(
              _exchangeService.getMisSolicitudes(currentUserId),
              'No has solicitado ningún material todavía.',
            ),
            // Pestaña 2: Lo que me piden a mí
            _buildExchangeList(
              _exchangeService.getSolicitudesRecibidas(currentUserId),
              'Nadie ha solicitado tus materiales todavía.',
            ),
          ],
        ),
      ),
    );
  }
}
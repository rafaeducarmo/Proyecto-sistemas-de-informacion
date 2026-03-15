import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/exchange_model.dart';

class ExchangeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Busca los libros que el estudiante actual le ha pedido a otros
  Stream<List<Exchange>> getMisSolicitudes(String userId) {
    return _db.collection('exchanges')
        .where('requesterId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Exchange.fromMap(doc.data())).toList());
  }

  // Busca las personas que le están pidiendo libros al estudiante actual
  Stream<List<Exchange>> getSolicitudesRecibidas(String userId) {
    return _db.collection('exchanges')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Exchange.fromMap(doc.data())).toList());
  }

  // --- NUEVA FUNCIÓN PARA LIMPIAR EL HISTORIAL ACEPTADO ---
  Future<void> clearAcceptedExchanges(String userId, bool isMisSolicitudes) async {
    try {
        final collection = _db.collection('exchanges');
        final queryField = isMisSolicitudes ? 'requesterId' : 'ownerId';

        final snapshot = await collection
          .where(queryField, isEqualTo: userId)
          .where('status', isEqualTo: 'Aceptado') // O ajusta si quieres borrar también rechazados
          .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
    } catch (e) {
      throw Exception('Error al limpiar el historial: $e');
    }
  }
}
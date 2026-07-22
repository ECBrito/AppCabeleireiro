import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class BookingDbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Guardar nova marcação
  Future<void> createBooking(Appointment appointment) async {
    await _db.collection('bookings').add({
      'clientName': appointment.clientName,
      'serviceName': appointment.serviceName,
      'price': appointment.price,
      'date': Timestamp.fromDate(appointment.date),
      'time': appointment.time,
      'shopId': appointment.shopId,
      'workerId': appointment.workerId,
      'workerName': appointment.workerName,
      'colorHex': appointment.colorHex,
      'status': appointment.status.name, // "pending", "confirmed", etc.
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream de marcações para a Dashboard
  Stream<List<Appointment>> getBookingsStream() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Appointment(
          id: doc.id,
          clientName: data['clientName'] ?? 'Cliente',
          serviceName: data['serviceName'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          time: data['time'] ?? '',
          shopId: data['shopId'] ?? '',
          workerId: data['workerId'] ?? '',
          workerName: data['workerName'] ?? '',
          colorHex: data['colorHex'] ?? 0xFFFFD700,
          status: AppointmentStatus.values.firstWhere(
                (e) => e.name == data['status'],
            orElse: () => AppointmentStatus.pending,
          ),
        );
      }).toList();
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/worker_model.dart';

class WorkerDbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream para obter profissionais em tempo real do Firestore
  Stream<List<Worker>> getWorkersStream() {
    return _db.collection('workers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Worker.fromDocument(doc)).toList();
    });
  }

  // Adicionar Profissional
  Future<void> addWorker(Worker worker) async {
    await _db.collection('workers').add(worker.toMap());
  }

  // Remover Profissional
  Future<void> deleteWorker(String id) async {
    await _db.collection('workers').doc(id).delete();
  }
}
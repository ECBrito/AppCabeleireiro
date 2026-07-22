import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceDbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream para ouvir atualizações em tempo real dos serviços
  Stream<List<ServiceModel>> getServicesStream() {
    return _db.collection('services').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ServiceModel.fromDocument(doc)).toList();
    });
  }

  // Adicionar um novo serviço
  Future<void> addService(ServiceModel service) async {
    await _db.collection('services').add(service.toMap());
  }

  // Atualizar um serviço existente
  Future<void> updateService(ServiceModel service) async {
    await _db.collection('services').doc(service.id).update(service.toMap());
  }

  // Apagar um serviço
  Future<void> deleteService(String serviceId) async {
    await _db.collection('services').doc(serviceId).delete();
  }
}
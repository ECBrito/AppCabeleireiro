import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ServiceDbService {
  static const String baseUrl = 'http://10.0.2.2:3000/services';

  // Obter todos os serviços
  Future<List<ServiceModel>> getServices({int shopId = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl?shopId=$shopId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar serviços');
    }
  }

  // Stream para manter compatibilidade com StreamBuilder (polling ou future stream)
  Stream<List<ServiceModel>> getServicesStream({int shopId = 1}) async* {
    yield await getServices(shopId: shopId);
  }

  // Adicionar um novo serviço
  Future<ServiceModel> addService(ServiceModel service) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(service.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return ServiceModel.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro ao adicionar serviço');
    }
  }

  // Atualizar serviço existente
  Future<void> updateService(ServiceModel service) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${service.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(service.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar serviço');
    }
  }

  // Apagar serviço
  Future<void> deleteService(int serviceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$serviceId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover serviço');
    }
  }
}
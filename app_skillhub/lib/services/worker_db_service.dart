import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/worker_model.dart';

class WorkerDbService {
  static const String baseUrl = 'http://10.0.2.2:3000/workers';

  // Obter lista de profissionais
  Future<List<Worker>> getWorkers({int shopId = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl?shopId=$shopId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Worker.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar profissionais');
    }
  }

  // Stream para manter compatibilidade com StreamBuilder nos ecrãs existentes
  Stream<List<Worker>> getWorkersStream({int shopId = 1}) async* {
    yield await getWorkers(shopId: shopId);
  }

  // Adicionar Profissional
  Future<Worker> addWorker(Worker worker) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(worker.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Worker.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro ao adicionar profissional');
    }
  }

  // Remover Profissional
  Future<void> deleteWorker(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover profissional');
    }
  }
}
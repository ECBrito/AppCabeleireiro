import 'dart:convert';
import 'package:http/http.dart' as http;

class ShopService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  // Buscar lojas
  static Future<List<Map<String, dynamic>>> getShops() async {
    final response = await http
        .get(Uri.parse('$baseUrl/shops'))
        .timeout(const Duration(seconds: 7));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception(
        'Erro ao carregar lojas (${response.statusCode}): ${response.body}',
      );
    }
  }

  // Buscar serviços da barbearia
  static Future<List<Map<String, dynamic>>> getServices({
    int shopId = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/services?shopId=$shopId'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erro ao carregar serviços');
    }
  }

  // Buscar profissionais da barbearia
  static Future<List<Map<String, dynamic>>> getWorkers({int shopId = 1}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/workers?shopId=$shopId'),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erro ao carregar profissionais');
    }
  }
}

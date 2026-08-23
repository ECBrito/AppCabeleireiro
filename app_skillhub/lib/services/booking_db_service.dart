import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment_model.dart';

class BookingDbService {
  static const String baseUrl = 'http://10.0.2.2:3000/bookings';

  // Obter agendamentos
  Future<List<Appointment>> getBookings({int shopId = 1, String? date}) async {
    String url = '$baseUrl?shopId=$shopId';
    if (date != null && date.isNotEmpty) {
      url += '&date=$date';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao obter marcações');
    }
  }

  // Stream para Dashboard
  Stream<List<Appointment>> getBookingsStream({int shopId = 1, String? date}) async* {
    yield await getBookings(shopId: shopId, date: date);
  }

  // Criar nova marcação
  Future<Appointment> createBooking(Appointment appointment) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(appointment.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro ao registar marcação');
    }
  }

  // Atualizar Estado da Marcação (ex: confirmar, cancelar)
  Future<void> updateBookingStatus(int bookingId, AppointmentStatus status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$bookingId/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar estado da marcação');
    }
  }
}
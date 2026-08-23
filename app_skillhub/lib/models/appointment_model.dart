import 'package:flutter/material.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  final int id;
  final int? clientId;
  final String clientName;
  final String serviceName;
  final double price;
  final DateTime date;
  final String time;
  final int shopId;
  final int? workerId;
  final String workerName;
  final int colorHex;
  AppointmentStatus status;

  Appointment({
    required this.id,
    this.clientId,
    required this.clientName,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.time,
    this.shopId = 1,
    this.workerId,
    required this.workerName,
    this.colorHex = 0xFFFFD700,
    this.status = AppointmentStatus.pending,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      clientId: json['client_id'] != null ? int.tryParse(json['client_id'].toString()) : null,
      clientName: json['client_name'] ?? 'Cliente',
      serviceName: json['service_name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      date: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'].toString())
          : DateTime.now(),
      time: json['booking_time'] ?? '',
      shopId: json['shop_id'] != null ? int.parse(json['shop_id'].toString()) : 1,
      workerId: json['worker_id'] != null ? int.tryParse(json['worker_id'].toString()) : null,
      workerName: json['worker_name'] ?? '',
      colorHex: 0xFFFFD700,
      status: AppointmentStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'client_name': clientName,
      'shop_id': shopId,
      'worker_id': workerId,
      'worker_name': workerName,
      'service_name': serviceName,
      'price': price,
      'booking_date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'booking_time': time,
      'status': status.name,
    };
  }

  Color get statusColor {
    switch (status) {
      case AppointmentStatus.pending: return Colors.orange;
      case AppointmentStatus.confirmed: return Colors.green;
      case AppointmentStatus.completed: return Colors.blue;
      case AppointmentStatus.cancelled: return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case AppointmentStatus.pending: return "Pendente";
      case AppointmentStatus.confirmed: return "Confirmado";
      case AppointmentStatus.completed: return "Concluído";
      case AppointmentStatus.cancelled: return "Cancelado";
    }
  }
}
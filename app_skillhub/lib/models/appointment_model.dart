import 'package:flutter/material.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled }

class Appointment {
  final String id;
  final String clientName;
  final String serviceName;
  final double price;
  final DateTime date;
  final String time;
  final String shopId;
  final String workerId;
  final String workerName;
  final int colorHex;
  
  // NOVO: Estado da marcação (Padrão: Pendente)
  AppointmentStatus status; 

  Appointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.time,
    required this.shopId,
    required this.workerId,
    required this.workerName,
    required this.colorHex,
    this.status = AppointmentStatus.pending,
  });

  // Helper para obter cor e texto do status
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
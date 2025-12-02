class Appointment {
  final String id;
  final String clientName;
  final String serviceName;
  final double price;
  final DateTime date;
  final String time;
  final String shopId; // Para saber a que loja pertence

  Appointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.time,
    required this.shopId,
  });
}
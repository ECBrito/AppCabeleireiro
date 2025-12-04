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
  final int colorHex; // Cor da loja para mostrar na lista

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
  });
}
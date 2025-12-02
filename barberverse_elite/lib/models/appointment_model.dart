class Appointment {
  final String id;
  final String clientName;
  final String serviceName;
  final double price;
  final DateTime date;
  final String time;
  final String shopId;
  final String workerId; // <--- NOVO CAMPO
  final String workerName; // <--- NOVO CAMPO (Para facilitar a exibição)

  Appointment({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.time,
    required this.shopId,
    required this.workerId,     // Obrigatório
    required this.workerName,   // Obrigatório
  });
}
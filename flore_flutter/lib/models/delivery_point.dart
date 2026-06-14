class DeliveryPoint {
  final String id;
  final String label;
  final String type;
  final double latitude;
  final double longitude;
  final String status;
  final String estimatedArrival;

  DeliveryPoint({
    required this.id,
    required this.label,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.estimatedArrival,
  });

  factory DeliveryPoint.fromJson(Map<String, dynamic> json) {
    return DeliveryPoint(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      estimatedArrival: json['estimatedArrival'] ?? '',
    );
  }

  static List<DeliveryPoint> mockPoints() {
    return [
      DeliveryPoint(id: 'w1', label: 'Armazém Florê', type: 'warehouse', latitude: -23.5505, longitude: -46.6333, status: 'Operacional', estimatedArrival: ''),
      DeliveryPoint(id: 'd1', label: 'Vestido Azul', type: 'delivery', latitude: -23.5615, longitude: -46.6560, status: 'Em trânsito', estimatedArrival: 'Hoje 18h'),
      DeliveryPoint(id: 'd2', label: 'Calça Jeans', type: 'delivery', latitude: -23.5489, longitude: -46.6388, status: 'No armazém', estimatedArrival: 'Amanhã 12h'),
      DeliveryPoint(id: 'p1', label: 'Correios - Centro', type: 'partner', latitude: -23.5430, longitude: -46.6290, status: 'Parceiro', estimatedArrival: ''),
      DeliveryPoint(id: 'p2', label: 'Jadlog - Vila Mariana', type: 'partner', latitude: -23.5880, longitude: -46.6340, status: 'Parceiro', estimatedArrival: ''),
    ];
  }
}

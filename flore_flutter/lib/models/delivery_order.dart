class TimelineEvent {
  final String title;
  final String description;
  final DateTime date;
  final bool completed;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.completed,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      completed: json['completed'] ?? false,
    );
  }
}

class DeliveryOrder {
  final String id;
  final String itemName;
  final String status;
  final String origin;
  final String destination;
  final String estimatedDelivery;
  final double progress;
  final List<TimelineEvent> timeline;

  DeliveryOrder({
    required this.id,
    required this.itemName,
    required this.status,
    required this.origin,
    required this.destination,
    required this.estimatedDelivery,
    required this.progress,
    required this.timeline,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      status: json['status'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      estimatedDelivery: json['estimatedDelivery'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
      timeline: (json['timeline'] as List<dynamic>? ?? [])
          .map((e) => TimelineEvent.fromJson(e))
          .toList(),
    );
  }

  static List<DeliveryOrder> mockOrders() {
    return [
      DeliveryOrder(
        id: '001',
        itemName: 'Vestido Azul com Flores',
        status: 'Em trânsito',
        origin: 'Armazém Florê - SP',
        destination: 'Rua das Flores, 42 - SP',
        estimatedDelivery: 'Hoje, até 18h',
        progress: 0.65,
        timeline: [
          TimelineEvent(title: 'Pedido confirmado', description: 'Sua compra foi confirmada', date: DateTime.now().subtract(const Duration(days: 2)), completed: true),
          TimelineEvent(title: 'No armazém', description: 'Peça separada e embalada', date: DateTime.now().subtract(const Duration(days: 1)), completed: true),
          TimelineEvent(title: 'Saiu para entrega', description: 'Entregador a caminho', date: DateTime.now().subtract(const Duration(hours: 3)), completed: true),
          TimelineEvent(title: 'Entregue', description: 'Aguardando entrega', date: DateTime.now(), completed: false),
        ],
      ),
      DeliveryOrder(
        id: '002',
        itemName: 'Calça Jeans Azul',
        status: 'No armazém',
        origin: 'Vendedor - Campinas',
        destination: 'Av. Paulista, 1000 - SP',
        estimatedDelivery: 'Amanhã, até 12h',
        progress: 0.35,
        timeline: [
          TimelineEvent(title: 'Pedido confirmado', description: 'Sua compra foi confirmada', date: DateTime.now().subtract(const Duration(days: 1)), completed: true),
          TimelineEvent(title: 'No armazém', description: 'Peça recebida no armazém Florê', date: DateTime.now(), completed: true),
          TimelineEvent(title: 'Saiu para entrega', description: 'Aguardando separação', date: DateTime.now().add(const Duration(days: 1)), completed: false),
          TimelineEvent(title: 'Entregue', description: 'Aguardando entrega', date: DateTime.now().add(const Duration(days: 1)), completed: false),
        ],
      ),
      DeliveryOrder(
        id: '003',
        itemName: 'Camiseta Branca Básica',
        status: 'Entregue',
        origin: 'Armazém Florê - SP',
        destination: 'Rua Augusta, 500 - SP',
        estimatedDelivery: 'Entregue ontem',
        progress: 1.0,
        timeline: [
          TimelineEvent(title: 'Pedido confirmado', description: 'Sua compra foi confirmada', date: DateTime.now().subtract(const Duration(days: 3)), completed: true),
          TimelineEvent(title: 'No armazém', description: 'Peça separada e embalada', date: DateTime.now().subtract(const Duration(days: 2)), completed: true),
          TimelineEvent(title: 'Saiu para entrega', description: 'Entregador a caminho', date: DateTime.now().subtract(const Duration(days: 1)), completed: true),
          TimelineEvent(title: 'Entregue', description: 'Entrega realizada com sucesso', date: DateTime.now().subtract(const Duration(days: 1)), completed: true),
        ],
      ),
    ];
  }
}

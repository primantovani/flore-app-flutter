// lib/models/delivery_model.dart

class DeliveryPoint {
  final String id;
  final String label;
  final String type; // 'user', 'warehouse', 'delivery', 'partner'
  final double latitude;
  final double longitude;
  final String status;
  final String? estimatedTime;

  DeliveryPoint({
    required this.id,
    required this.label,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.estimatedTime,
  });

  factory DeliveryPoint.fromJson(Map<String, dynamic> json) {
    return DeliveryPoint(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      status: json['status'],
      estimatedTime: json['estimated_time'],
    );
  }
}

class DeliveryOrder {
  final String orderId;
  final String itemName;
  final String status;
  final String origin;
  final String destination;
  final String estimatedDelivery;
  final double progress; // 0.0 a 1.0
  final List<DeliveryEvent> timeline;

  DeliveryOrder({
    required this.orderId,
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
      orderId: json['order_id'],
      itemName: json['item_name'],
      status: json['status'],
      origin: json['origin'],
      destination: json['destination'],
      estimatedDelivery: json['estimated_delivery'],
      progress: json['progress'].toDouble(),
      timeline: (json['timeline'] as List)
          .map((e) => DeliveryEvent.fromJson(e))
          .toList(),
    );
  }
}

class DeliveryEvent {
  final String title;
  final String description;
  final String time;
  final bool completed;

  DeliveryEvent({
    required this.title,
    required this.description,
    required this.time,
    required this.completed,
  });

  factory DeliveryEvent.fromJson(Map<String, dynamic> json) {
    return DeliveryEvent(
      title: json['title'],
      description: json['description'],
      time: json['time'],
      completed: json['completed'],
    );
  }
}

enum ClosetItemStatus { available, sold }

class ClosetItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final ClosetItemStatus status;
  final String ownerId;
  final String ownerName;

  const ClosetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    required this.ownerId,
    required this.ownerName,
    this.description,
  });

  factory ClosetItem.fromJson(Map<String, dynamic> json) {
    return ClosetItem(
      id: json['id'].toString(),
      name: json['name'] as String? ?? json['nome'] as String? ?? '',
      category: json['category'] as String? ?? json['categoria'] as String? ?? '',
      price: (json['price'] ?? json['valor'] ?? 0).toDouble(),
      description: json['description'] as String?,
      status: (json['status'] == 'sold' || json['status'] == 'Vendido')
          ? ClosetItemStatus.sold
          : ClosetItemStatus.available,
      ownerId: (json['ownerId'] ?? json['owner_id'] ?? '').toString(),
      ownerName: json['ownerName'] as String? ?? json['owner_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'category': category,
        'price': price,
        if (description != null && description!.isNotEmpty) 'description': description,
      };

  bool get isAvailable => status == ClosetItemStatus.available;

  ClosetItem copyWith({
    String? name,
    String? category,
    double? price,
    String? description,
    ClosetItemStatus? status,
  }) {
    return ClosetItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      status: status ?? this.status,
      ownerId: ownerId,
      ownerName: ownerName,
    );
  }
}

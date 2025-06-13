class WishlistModel {
  final String id;
  final String userId;
  final List<String> productIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  WishlistModel({
    required this.id,
    required this.userId,
    this.productIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory WishlistModel.fromMap(Map<String, dynamic> map) {
    return WishlistModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      productIds: List<String>.from(map['productIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productIds': productIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  WishlistModel copyWith({
    String? id,
    String? userId,
    List<String>? productIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productIds: productIds ?? this.productIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool containsProduct(String productId) {
    return productIds.contains(productId);
  }

  WishlistModel addProduct(String productId) {
    if (!productIds.contains(productId)) {
      return copyWith(
        productIds: [...productIds, productId],
        updatedAt: DateTime.now(),
      );
    }
    return this;
  }

  WishlistModel removeProduct(String productId) {
    return copyWith(
      productIds: productIds.where((id) => id != productId).toList(),
      updatedAt: DateTime.now(),
    );
  }
}

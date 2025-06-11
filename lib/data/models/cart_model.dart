import '/exports.dart';

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)?.map((e) => CartItemModel.fromMap(e)).toList() ?? [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Calculate total price
  double get totalPrice {
    return items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  // Calculate total items count
  int get totalItems {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  // Check if cart is empty
  bool get isEmpty => items.isEmpty;

  // Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  CartModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CartItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double discountPrice;
  final int quantity;
  final String unit;
  final DateTime addedAt;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.discountPrice = 0.0,
    required this.quantity,
    required this.unit,
    required this.addedAt,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] ?? '',
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'discountPrice': discountPrice,
      'quantity': quantity,
      'unit': unit,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  // Get effective price per item
  double get effectivePrice => discountPrice > 0 ? discountPrice : price;

  // Calculate total price for this item
  double get totalPrice => effectivePrice * quantity;

  // Check if item has discount
  bool get hasDiscount => discountPrice > 0 && discountPrice < price;

  CartItemModel copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? discountPrice,
    int? quantity,
    String? unit,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Create CartItemModel from ProductModel
  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItemModel(
      productId: product.id,
      productName: product.name,
      productImage: product.primaryImageUrl,
      price: product.price,
      discountPrice: product.discountPrice,
      quantity: quantity,
      unit: product.unit,
      addedAt: DateTime.now(),
    );
  }
}

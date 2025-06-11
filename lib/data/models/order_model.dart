import '/exports.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final AddressModel deliveryAddress;
  final String paymentMethod;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final String? notes;
  final String? trackingNumber;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.status,
    required this.subtotal,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
    required this.total,
    required this.orderDate,
    this.estimatedDelivery,
    this.actualDelivery,
    this.notes,
    this.trackingNumber,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>?)?.map((e) => OrderItemModel.fromMap(e)).toList() ?? [],
      deliveryAddress: AddressModel.fromMap(map['deliveryAddress'] ?? {}),
      paymentMethod: map['paymentMethod'] ?? '',
      status: map['status'] ?? '',
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate'] ?? 0),
      estimatedDelivery:
          map['estimatedDelivery'] != null ? DateTime.fromMillisecondsSinceEpoch(map['estimatedDelivery']) : null,
      actualDelivery: map['actualDelivery'] != null ? DateTime.fromMillisecondsSinceEpoch(map['actualDelivery']) : null,
      notes: map['notes'],
      trackingNumber: map['trackingNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'deliveryAddress': deliveryAddress.toMap(),
      'paymentMethod': paymentMethod,
      'status': status,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'estimatedDelivery': estimatedDelivery?.millisecondsSinceEpoch,
      'actualDelivery': actualDelivery?.millisecondsSinceEpoch,
      'notes': notes,
      'trackingNumber': trackingNumber,
    };
  }

  // Calculate total items count
  int get totalItems {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  // Check if order can be cancelled
  bool get canBeCancelled {
    return status == AppConstants.orderPending || status == AppConstants.orderConfirmed;
  }

  // Check if order is delivered
  bool get isDelivered => status == AppConstants.orderDelivered;

  // Check if order is cancelled
  bool get isCancelled => status == AppConstants.orderCancelled;

  // Get status display text
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case AppConstants.orderPending:
        return 'Pending';
      case AppConstants.orderConfirmed:
        return 'Confirmed';
      case AppConstants.orderProcessing:
        return 'Processing';
      case AppConstants.orderShipped:
        return 'Shipped';
      case AppConstants.orderDelivered:
        return 'Delivered';
      case AppConstants.orderCancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItemModel>? items,
    AddressModel? deliveryAddress,
    String? paymentMethod,
    String? status,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? total,
    DateTime? orderDate,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    String? notes,
    String? trackingNumber,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      notes: notes ?? this.notes,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }
}

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final double discountPrice;
  final int quantity;
  final String unit;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.discountPrice = 0.0,
    required this.quantity,
    required this.unit,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      unit: map['unit'] ?? '',
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
    };
  }

  // Get effective price per item
  double get effectivePrice => discountPrice > 0 ? discountPrice : price;

  // Calculate total price for this item
  double get totalPrice => effectivePrice * quantity;

  // Check if item has discount
  bool get hasDiscount => discountPrice > 0 && discountPrice < price;

  OrderItemModel copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? discountPrice,
    int? quantity,
    String? unit,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  // Create OrderItemModel from CartItemModel
  factory OrderItemModel.fromCartItem(CartItemModel cartItem) {
    return OrderItemModel(
      productId: cartItem.productId,
      productName: cartItem.productName,
      productImage: cartItem.productImage,
      price: cartItem.price,
      discountPrice: cartItem.discountPrice,
      quantity: cartItem.quantity,
      unit: cartItem.unit,
    );
  }
}

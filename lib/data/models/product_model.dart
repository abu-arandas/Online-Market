class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final String category;
  final String brand;
  final List<String> imageUrls;
  final String unit;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? barcode;
  final Map<String, dynamic> nutritionInfo;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice = 0.0,
    required this.category,
    required this.brand,
    this.imageUrls = const [],
    required this.unit,
    required this.stockQuantity,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.barcode,
    this.nutritionInfo = const {},
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      brand: map['brand'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      unit: map['unit'] ?? '',
      stockQuantity: map['stockQuantity'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      barcode: map['barcode'],
      nutritionInfo: Map<String, dynamic>.from(map['nutritionInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'category': category,
      'brand': brand,
      'imageUrls': imageUrls,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'barcode': barcode,
      'nutritionInfo': nutritionInfo,
    };
  }

  // Calculate effective price (with discount if available)
  double get effectivePrice => discountPrice > 0 ? discountPrice : price;

  // Calculate discount percentage
  double get discountPercentage {
    if (discountPrice <= 0 || discountPrice >= price) return 0.0;
    return ((price - discountPrice) / price) * 100;
  }

  // Check if product has discount
  bool get hasDiscount => discountPrice > 0 && discountPrice < price;

  // Get primary image URL
  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  // Check if product is in stock
  bool get isInStock => stockQuantity > 0 && isAvailable;

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? category,
    String? brand,
    List<String>? imageUrls,
    String? unit,
    int? stockQuantity,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? barcode,
    Map<String, dynamic>? nutritionInfo,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      imageUrls: imageUrls ?? this.imageUrls,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      barcode: barcode ?? this.barcode,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
    );
  }
}

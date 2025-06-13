class PromoCodeModel {
  final String id;
  final String code;
  final String description;
  final double discountPercentage;
  final double discountAmount;
  final double minimumOrderAmount;
  final double maximumDiscountAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final int usageLimit;
  final int usedCount;
  final List<String> applicableCategories;
  final List<String> excludedProducts;
  final String discountType; // percentage, fixed_amount, free_shipping
  final DateTime createdAt;
  final DateTime updatedAt;

  PromoCodeModel({
    required this.id,
    required this.code,
    required this.description,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.minimumOrderAmount = 0.0,
    this.maximumDiscountAmount = 0.0,
    required this.validFrom,
    required this.validUntil,
    this.isActive = true,
    this.usageLimit = 0,
    this.usedCount = 0,
    this.applicableCategories = const [],
    this.excludedProducts = const [],
    this.discountType = 'percentage',
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromoCodeModel.fromMap(Map<String, dynamic> map) {
    return PromoCodeModel(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      discountPercentage: (map['discountPercentage'] ?? 0.0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0.0).toDouble(),
      minimumOrderAmount: (map['minimumOrderAmount'] ?? 0.0).toDouble(),
      maximumDiscountAmount: (map['maximumDiscountAmount'] ?? 0.0).toDouble(),
      validFrom: DateTime.fromMillisecondsSinceEpoch(map['validFrom'] ?? 0),
      validUntil: DateTime.fromMillisecondsSinceEpoch(map['validUntil'] ?? 0),
      isActive: map['isActive'] ?? true,
      usageLimit: map['usageLimit'] ?? 0,
      usedCount: map['usedCount'] ?? 0,
      applicableCategories: List<String>.from(map['applicableCategories'] ?? []),
      excludedProducts: List<String>.from(map['excludedProducts'] ?? []),
      discountType: map['discountType'] ?? 'percentage',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'minimumOrderAmount': minimumOrderAmount,
      'maximumDiscountAmount': maximumDiscountAmount,
      'validFrom': validFrom.millisecondsSinceEpoch,
      'validUntil': validUntil.millisecondsSinceEpoch,
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'applicableCategories': applicableCategories,
      'excludedProducts': excludedProducts,
      'discountType': discountType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  bool isValid() {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(validFrom) &&
        now.isBefore(validUntil) &&
        (usageLimit == 0 || usedCount < usageLimit);
  }

  double calculateDiscount(double orderAmount, List<String> productIds) {
    if (!isValid() || orderAmount < minimumOrderAmount) {
      return 0.0;
    }

    double discount = 0.0;

    switch (discountType) {
      case 'percentage':
        discount = orderAmount * (discountPercentage / 100);
        if (maximumDiscountAmount > 0 && discount > maximumDiscountAmount) {
          discount = maximumDiscountAmount;
        }
        break;
      case 'fixed_amount':
        discount = discountAmount;
        break;
      case 'free_shipping':
        // Handle free shipping logic elsewhere
        discount = 0.0;
        break;
    }

    return discount;
  }
}

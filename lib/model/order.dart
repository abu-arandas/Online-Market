import '/exports.dart';

class OrderModel {
  String id, customer;
  String? driver;
  DateTime start;
  DateTime? pick, deliver;
  LatLng customerAddress;
  List<ProductModel> products;
  PromoCodeModel? promoCode;
  OrderProgress progress;
  PaymentType? payment;

  OrderModel({
    required this.id,
    required this.customer,
    this.driver,
    required this.start,
    this.pick,
    this.deliver,
    required this.customerAddress,
    required this.products,
    this.promoCode,
    required this.progress,
    this.payment,
  });

  factory OrderModel.fromJson(DocumentSnapshot data) => OrderModel(
        id: data.id,
        customer: data['customer'],
        driver: data['driver'],
        start: (data['start']).toDate(),
        pick: data['pick'] != null ? (data['pick']).toDate() : null,
        deliver: data['deliver'] != null ? (data['deliver']).toDate() : null,
        customerAddress: LatLng.fromJson(data['customerAddress']),
        products: List<ProductModel>.from(
            data['products'].map((x) => ProductModel.fromMap(x))),
        promoCode: data['promoCode'] != null
            ? PromoCodeModel.fromJson(data['promoCode'])
            : null,
        progress: orderProgress.map[data['progress']]!,
        payment:
            data['payment'] != null ? paymentType.map[data['payment']] : null,
      );

  Map<String, dynamic> toJson() => {
        'customer': customer,
        'driver': driver,
        'start': start,
        'pick': pick,
        'deliver': deliver,
        'customerAddress': customerAddress.toJson(),
        'products': List<Map>.from(products.map((x) => x.toJson())),
        'promoCode': promoCode?.toJson(),
        'progress': orderProgress.reverse[progress],
        'payment': paymentType.reverse[payment],
      };
}

enum OrderProgress { preparing, delivering, done, deleted }

EnumValues<OrderProgress> orderProgress = EnumValues({
  '0': OrderProgress.preparing,
  '1': OrderProgress.delivering,
  '2': OrderProgress.done,
  '99': OrderProgress.deleted,
});

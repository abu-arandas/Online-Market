import '/exports.dart';

enum PaymentType { cash, creditcard }

EnumValues<PaymentType> paymentType = EnumValues({
  'Cash on deliver': PaymentType.cash,
  'Credit Card': PaymentType.creditcard,
});

Color progressColor(OrderProgress progress) {
  switch (progress) {
    case OrderProgress.preparing:
      return const Color(0xFF01b075);
    case OrderProgress.delivering:
      return const Color(0xFF007bff);
    case OrderProgress.done:
      return const Color(0xFF28a745);
    case OrderProgress.deleted:
      return const Color(0xFFdc3545);
  }
}

TextString progressDetails(OrderProgress progress) {
  switch (progress) {
    case OrderProgress.preparing:
      return TextString(en: 'Your order is preparing', ar: 'طلبك قيد التحضير');
    case OrderProgress.delivering:
      return TextString(
          en: 'We are delivering this order to you', ar: 'نقوم بتوصيله اليك');
    case OrderProgress.done:
      return TextString(en: 'Finished', ar: 'تم الانتهاء');
    case OrderProgress.deleted:
      return TextString(en: 'Deleted', ar: 'تم حذفه');
  }
}

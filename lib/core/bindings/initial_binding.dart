import '/exports.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put(FirebaseService(), permanent: true);
    Get.put(MappingService(), permanent: true);
    Get.put(ScanningService(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(SearchService(), permanent: true);
    Get.put(BiometricService(), permanent: true);
    Get.put(PaymentService(), permanent: true);
    Get.put(OrderTrackingService(), permanent: true);
    Get.put(VoiceSearchService(), permanent: true);
    Get.put(ARService(), permanent: true);

    // Repositories
    Get.put(AuthRepository(), permanent: true);
    Get.put(ProductRepository(), permanent: true);
    Get.put(CartRepository(), permanent: true);
    Get.put(OrderRepository(), permanent: true);
    Get.put(WishlistRepository(), permanent: true);
    Get.put(ReviewRepository(), permanent: true);
    Get.put(NotificationRepository(), permanent: true);

    // Controllers
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => SearchController());
    Get.lazyPut(() => WishlistController());
    Get.lazyPut(() => NotificationController());
    Get.lazyPut(() => SettingsController());
    Get.lazyPut(() => MainNavigationController());
  }
}

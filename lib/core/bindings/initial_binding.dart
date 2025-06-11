import '/exports.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put(FirebaseService(), permanent: true);
    Get.put(MappingService(), permanent: true);
    Get.put(ScanningService(), permanent: true);

    // Initialize GetStorage
    Get.putAsync(() => GetStorage.init().then((_) => GetStorage()), permanent: true);

    // Controllers
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => MapController());
  }
}

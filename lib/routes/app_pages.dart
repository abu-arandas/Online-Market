import '/exports.dart';
import '../modules/map/controllers/map_controller.dart' as local;

class AppPages {
  static const String initial = AppRoutes.home;

  static final routes = [
    // Auth Pages
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),

    // Main Pages
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CartController());
      }),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CartController());
      }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController());
      }),
    ),
    GetPage(
      name: AppRoutes.map,
      page: () => const MapView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => local.MapController());
      }),
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderHistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OrderHistoryController());
      }),
    ),
  ];
}

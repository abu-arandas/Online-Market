import '/exports.dart';
import '../modules/controllers/map_controller.dart' as local;

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
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SearchController());
      }),
    ),
    GetPage(
      name: AppRoutes.wishlist,
      page: () => const WishlistView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WishlistController());
      }),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotificationController());
      }),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SettingsController());
        Get.lazyPut(() => ThemeController());
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

    // Product Pages
    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProductDetailController());
      }),
    ),

    // Review Pages
    GetPage(
      name: AppRoutes.writeReview,
      page: () => const WriteReviewView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WriteReviewController());
      }),
    ),

    // Order Tracking Pages
    GetPage(
      name: AppRoutes.orderTracking,
      page: () => const OrderTrackingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OrderTrackingController());
      }),
    ),

    // Onboarding Pages
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController());
      }),
    ),

    // Review Pages
    GetPage(
      name: AppRoutes.writeReview,
      page: () => const WriteReviewView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => WriteReviewController());
      }),
    ),

    // Order Tracking Pages
    GetPage(
      name: AppRoutes.orderTracking,
      page: () => const OrderTrackingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OrderTrackingController());
      }),
    ),

    // Onboarding Pages
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OnboardingController());
      }),
    ),
  ];
}

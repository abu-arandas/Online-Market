import '/exports.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final currentPage = 0.obs;

  // Onboarding pages
  final List<OnboardingPage> pages = [
    OnboardingPage(
      type: OnboardingPageType.welcome,
      title: 'Welcome to Online Market',
      description:
          'Your one-stop destination for fresh groceries, delivered right to your doorstep with love and care.',
      imagePath: 'assets/images/online_groceries.png',
      icon: Icons.shopping_cart,
      color: AppConstants.primaryColor,
    ),
    OnboardingPage(
      type: OnboardingPageType.features,
      title: 'Fresh & Quality Products',
      description: 'We partner with the best suppliers to bring you the freshest products at competitive prices.',
      imagePath: '',
      icon: Icons.eco,
      color: Colors.green,
    ),
    OnboardingPage(
      type: OnboardingPageType.delivery,
      title: 'Fast & Reliable Delivery',
      description: 'Get your groceries delivered in as fast as 30 minutes. Track your order in real-time.',
      imagePath: '',
      icon: Icons.delivery_dining,
      color: Colors.orange,
    ),
    OnboardingPage(
      type: OnboardingPageType.scanning,
      title: 'Smart Shopping Features',
      description: 'Scan barcodes to add items quickly, use voice search, and get personalized recommendations.',
      imagePath: '',
      icon: Icons.qr_code_scanner,
      color: Colors.purple,
    ),
    OnboardingPage(
      type: OnboardingPageType.permissions,
      title: 'App Permissions',
      description: 'To provide you with the best experience, we need access to a few features on your device.',
      imagePath: '',
      icon: Icons.security,
      color: Colors.blue,
    ),
    OnboardingPage(
      type: OnboardingPageType.notifications,
      title: 'Stay in the Loop',
      description: 'Enable notifications to get updates about your orders, special offers, and more.',
      imagePath: '',
      icon: Icons.notifications,
      color: Colors.amber,
    ),
  ];

  bool get isLastPage => currentPage.value == pages.length - 1;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Page navigation
  void updateCurrentPage(int page) {
    currentPage.value = page;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    completeOnboarding();
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    try {
      // Request necessary permissions
      await _requestPermissions();

      // Navigate to login or home
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      AppHelpers.showSnackBar('Failed to complete onboarding', isError: true);
    }
  }

  // Enable notifications
  Future<void> enableNotifications() async {
    try {
      final notificationService = Get.find<NotificationService>();
      await notificationService.requestPermissions();
      AppHelpers.showSnackBar('Notifications enabled successfully');
    } catch (e) {
      AppHelpers.showSnackBar('Failed to enable notifications', isError: true);
    }
  }

  // Request app permissions
  Future<void> _requestPermissions() async {
    try {
      // Request location permission
      final permission = Permission.location;
      if (await permission.isDenied) {
        await permission.request();
      }

      // Request camera permission
      final cameraPermission = Permission.camera;
      if (await cameraPermission.isDenied) {
        await cameraPermission.request();
      }

      // Request notification permission
      final notificationPermission = Permission.notification;
      if (await notificationPermission.isDenied) {
        await notificationPermission.request();
      }
    } catch (e) {
      // Silently handle permission errors
      AppHelpers.logError('Permission request failed: $e');
    }
  }
}

// Onboarding models
class OnboardingPage {
  final OnboardingPageType type;
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.type,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.color,
  });
}

enum OnboardingPageType {
  welcome,
  features,
  delivery,
  scanning,
  permissions,
  notifications,
}

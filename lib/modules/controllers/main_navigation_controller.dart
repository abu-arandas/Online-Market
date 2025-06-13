import '/exports.dart';

class MainNavigationController extends GetxController {
  final currentIndex = 0.obs;

  final List<String> routes = [
    '/home',
    '/search',
    '/cart',
    '/wishlist',
    '/profile',
  ];

  void changePage(int index) {
    if (index == currentIndex.value) return;

    currentIndex.value = index;
    Get.offAllNamed(routes[index]);
  }

  void goToNotifications() {
    Get.toNamed('/notifications');
  }

  void goToSettings() {
    Get.toNamed('/settings');
  }
}

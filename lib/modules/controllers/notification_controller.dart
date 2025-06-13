import '/exports.dart';

class NotificationController extends GetxController {
  final NotificationRepository _notificationRepository = Get.find<NotificationRepository>();
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_authController.currentUser.value == null) return;

    try {
      isLoading.value = true;
      final userId = _authController.currentUser.value!.id;

      // Watch notifications changes
      _notificationRepository.watchUserNotifications(userId).listen((userNotifications) {
        notifications.value = userNotifications;
      });

      // Watch unread count
      _notificationRepository.watchUnreadCount(userId).listen((count) {
        unreadCount.value = count;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load notifications: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    if (_authController.currentUser.value == null) return;

    try {
      final userId = _authController.currentUser.value!.id;
      final userNotifications = await _notificationRepository.getUserNotifications(userId);
      notifications.value = userNotifications;

      final count = await _notificationRepository.getUnreadCount(userId);
      unreadCount.value = count;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh notifications: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    try {
      await _notificationRepository.markAsRead(notification.id);

      // Update local state
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.markAsRead();
        notifications.refresh();
      }

      // Decrease unread count
      if (unreadCount.value > 0) {
        unreadCount.value--;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_authController.currentUser.value == null || unreadCount.value == 0) return;

    try {
      final userId = _authController.currentUser.value!.id;
      await _notificationRepository.markAllAsRead(userId);

      // Update local state
      notifications.value = notifications.map((n) => n.markAsRead()).toList();
      unreadCount.value = 0;

      Get.snackbar(
        'Success',
        'All notifications marked as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all as read: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteNotification(NotificationModel notification) async {
    try {
      await _notificationRepository.deleteNotification(notification.id);

      // Update local state
      notifications.removeWhere((n) => n.id == notification.id);

      if (!notification.isRead && unreadCount.value > 0) {
        unreadCount.value--;
      }

      Get.snackbar(
        'Deleted',
        'Notification deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void onNotificationTapped(NotificationModel notification) {
    // Mark as read when tapped
    markAsRead(notification);

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'order_update':
        if (notification.data.containsKey('orderId')) {
          Get.toNamed('/order-details', arguments: notification.data['orderId']);
        } else {
          Get.toNamed('/order-history');
        }
        break;
      case 'promotion':
        if (notification.actionUrl != null) {
          // Handle deep links or specific product/category navigation
          _handleActionUrl(notification.actionUrl!);
        } else {
          Get.toNamed('/home');
        }
        break;
      case 'abandoned_cart':
        Get.toNamed('/cart');
        break;
      default:
        // For general notifications, just mark as read
        break;
    }
  }

  void _handleActionUrl(String actionUrl) {
    try {
      if (actionUrl.startsWith('/')) {
        // Internal route
        Get.toNamed(actionUrl);
      } else if (actionUrl.startsWith('product:')) {
        // Product deep link
        final productId = actionUrl.replaceFirst('product:', '');
        Get.toNamed('/product-details', arguments: productId);
      } else if (actionUrl.startsWith('category:')) {
        // Category deep link
        final category = actionUrl.replaceFirst('category:', '');
        Get.toNamed('/category', arguments: category);
      } else {
        // External URL
        launchUrl(Uri.parse(actionUrl));
      }
    } catch (e) {
      print('Error handling action URL: $e');
    }
  }

  String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Color getNotificationColor(String type) {
    switch (type) {
      case 'order_update':
        return Colors.blue;
      case 'promotion':
        return Colors.green;
      case 'abandoned_cart':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData getNotificationIcon(String type) {
    switch (type) {
      case 'order_update':
        return Icons.local_shipping;
      case 'promotion':
        return Icons.local_offer;
      case 'abandoned_cart':
        return Icons.shopping_cart;
      default:
        return Icons.notifications;
    }
  }

  bool get hasNotifications => notifications.isNotEmpty;

  bool get hasUnreadNotifications => unreadCount.value > 0;

  List<NotificationModel> get unreadNotifications => notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get readNotifications => notifications.where((n) => n.isRead).toList();
}

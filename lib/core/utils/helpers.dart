import '/exports.dart';
import 'dart:async';

class AppHelpers {
  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  // Validate password
  static bool isValidPassword(String password) {
    return password.length >= Config.minPasswordLength;
  }

  // Show snackbar
  static void showSnackBar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      backgroundColor: isError ? AppConstants.errorColor : AppConstants.successColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppConstants.spacing16),
      borderRadius: AppConstants.radiusMedium,
      duration: const Duration(seconds: 3),
    );
  }

  // Show loading dialog
  static void showLoading([String? message]) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
              if (message != null) ...[
                const SizedBox(height: AppConstants.spacing16),
                Text(
                  message,
                  style: AppConstants.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // Show confirmation dialog
  static Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText ?? 'Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Calculate distance between two coordinates
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Get readable file size
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Check network connectivity
  static Future<bool> hasNetworkConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    return !connectivity.contains(ConnectivityResult.none);
  }

  // Launch URL
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showSnackBar('Could not launch $url', isError: true);
    }
  }

  // Copy to clipboard
  static void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackBar('Copied to clipboard');
  }

  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Format product rating
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  // Get order status color
  static Color getOrderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case AppConstants.orderConfirmed:
      case AppConstants.orderDelivered:
        return AppConstants.successColor;
      case AppConstants.orderProcessing:
      case AppConstants.orderShipped:
        return AppConstants.accentColor;
      case AppConstants.orderCancelled:
        return AppConstants.errorColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  // Calculate cart total
  static double calculateCartTotal(List<dynamic> cartItems) {
    return cartItems.fold(0.0, (total, item) {
      return total + (item['price'] * item['quantity']);
    });
  }

  // Apply discount
  static double applyDiscount(double amount, double discountPercent) {
    return amount - (amount * discountPercent / 100);
  }
}

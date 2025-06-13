import '/exports.dart';

class OrderTrackingController extends GetxController {
  final OrderTrackingService _trackingService = Get.find<OrderTrackingService>();

  // Reactive variables
  final tracking = Rxn<OrderTracking>();
  final isLoading = false.obs;

  // Order ID
  String? orderId;

  @override
  void onInit() {
    super.onInit();
    _initializeTracking();
  }

  void _initializeTracking() {
    final args = Get.arguments;
    if (args is String) {
      orderId = args;
      loadTracking();
    } else if (args is Map<String, dynamic>) {
      orderId = args['orderId'];
      if (orderId != null) {
        loadTracking();
      }
    }
  }

  // Load tracking information
  Future<void> loadTracking() async {
    if (orderId == null) return;

    try {
      isLoading.value = true;
      final trackingData = await _trackingService.getOrderTracking(orderId!);
      tracking.value = trackingData;

      if (trackingData == null) {
        AppHelpers.showSnackBar('Order tracking not found', isError: true);
      }
    } catch (e) {
      AppHelpers.showSnackBar('Failed to load tracking information', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh tracking
  Future<void> refreshTracking() async {
    await loadTracking();
    AppHelpers.showSnackBar('Tracking information updated');
  }

  // Contact courier
  void contactCourier(String phoneNumber) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusLarge),
            topRight: Radius.circular(AppConstants.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contact Delivery Partner',
              style: AppConstants.headingSmall,
            ),
            const SizedBox(height: AppConstants.spacing16),
            Text(
              phoneNumber,
              style: AppConstants.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacing20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Call',
                    onPressed: () => _makePhoneCall(phoneNumber),
                    icon: Icons.phone,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),
                Expanded(
                  child: CustomButton(
                    text: 'Message',
                    onPressed: () => _sendMessage(phoneNumber),
                    isOutlined: true,
                    icon: Icons.message,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Share live location
  void shareLiveLocation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Share Live Location'),
        content: const Text(
          'Would you like to share your live location with the delivery partner to help them find you?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _shareLocation();
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  // Get support
  void getSupport() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.spacing20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusLarge),
            topRight: Radius.circular(AppConstants.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Need Help?',
              style: AppConstants.headingSmall,
            ),
            const SizedBox(height: AppConstants.spacing16),
            _buildSupportOption(
              icon: Icons.chat,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: _openLiveChat,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildSupportOption(
              icon: Icons.phone,
              title: 'Call Support',
              subtitle: 'Speak with a support agent',
              onTap: _callSupport,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildSupportOption(
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'Send us an email',
              onTap: _emailSupport,
            ),
            const SizedBox(height: AppConstants.spacing12),
            _buildSupportOption(
              icon: Icons.cancel,
              title: 'Cancel Order',
              subtitle: 'Cancel this order',
              onTap: _cancelOrder,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppConstants.errorColor : AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: AppConstants.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppConstants.errorColor : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppConstants.bodySmall.copyWith(
          color: AppConstants.textSecondaryColor,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
    );
  }

  // Private methods
  void _makePhoneCall(String phoneNumber) {
    Get.back();
    AppHelpers.launchURL('tel:$phoneNumber');
  }

  void _sendMessage(String phoneNumber) {
    Get.back();
    AppHelpers.launchURL('sms:$phoneNumber');
  }

  void _shareLocation() {
    // In a real app, you would implement live location sharing
    AppHelpers.showSnackBar('Live location sharing started');
  }

  void _openLiveChat() {
    Get.back();
    // Navigate to live chat or open chat widget
    AppHelpers.showSnackBar('Opening live chat...');
  }

  void _callSupport() {
    Get.back();
    AppHelpers.launchURL('tel:+1234567890');
  }

  void _emailSupport() {
    Get.back();
    AppHelpers.launchURL('mailto:support@onlinemarket.com?subject=Order Support - ${orderId ?? 'Unknown'}');
  }

  void _cancelOrder() {
    Get.back();
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep Order'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _processCancelOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  Future<void> _processCancelOrder() async {
    if (orderId == null || tracking.value == null) return;

    try {
      await _trackingService.updateOrderStatus(
        orderId: orderId!,
        status: OrderTrackingStatus.cancelled,
        location: 'Customer Request',
        description: 'Order cancelled by customer',
      );

      AppHelpers.showSnackBar('Order cancelled successfully');
      await refreshTracking();
    } catch (e) {
      AppHelpers.showSnackBar('Failed to cancel order', isError: true);
    }
  }
}

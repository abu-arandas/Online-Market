import '/exports.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshTracking,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.tracking.value == null) {
          return _buildNotFoundState();
        }

        return _buildTrackingContent();
      }),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 80,
              color: AppConstants.textSecondaryColor,
            ),
            const SizedBox(height: AppConstants.spacing16),
            const Text(
              'Order Not Found',
              style: AppConstants.headingMedium,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Unable to find tracking information for this order',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            CustomButton(
              text: 'Back to Orders',
              onPressed: () => Get.back(),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingContent() {
    final tracking = controller.tracking.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildOrderHeader(tracking),
          const SizedBox(height: AppConstants.spacing20),

          // Delivery Progress
          _buildDeliveryProgress(tracking),
          const SizedBox(height: AppConstants.spacing24),

          // Current Status
          _buildCurrentStatus(tracking),
          const SizedBox(height: AppConstants.spacing24),

          // Delivery Details
          _buildDeliveryDetails(tracking),
          const SizedBox(height: AppConstants.spacing24),

          // Timeline
          _buildTimeline(tracking),
          const SizedBox(height: AppConstants.spacing24),

          // Actions
          _buildActions(tracking),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(OrderTracking tracking) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Details',
                style: AppConstants.headingSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacing12,
                  vertical: AppConstants.spacing4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(tracking.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                  border: Border.all(
                    color: _getStatusColor(tracking.status).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(tracking.status),
                  style: AppConstants.bodySmall.copyWith(
                    color: _getStatusColor(tracking.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildDetailRow('Order ID', tracking.orderId),
          _buildDetailRow('Tracking Number', tracking.trackingNumber),
          _buildDetailRow('Current Location', tracking.currentLocation),
          _buildDetailRow(
            'Estimated Delivery',
            AppHelpers.formatDateTime(tracking.estimatedDelivery),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppConstants.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryProgress(OrderTracking tracking) {
    final currentStep = _getCurrentStep(tracking.status);
    const totalSteps = 6;
    final progress = currentStep / totalSteps;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Progress',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStatusColor(tracking.status),
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),

          Text(
            '${(progress * 100).toInt()}% Complete',
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(OrderTracking tracking) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: _getStatusColor(tracking.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Icon(
              _getStatusIcon(tracking.status),
              color: _getStatusColor(tracking.status),
              size: 32,
            ),
          ),
          const SizedBox(width: AppConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(tracking.status),
                  style: AppConstants.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  _getStatusDescription(tracking.status),
                  style: AppConstants.bodyMedium.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                if (tracking.timeline.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    'Updated ${AppHelpers.formatDateTime(tracking.timeline.last.timestamp)}',
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails(OrderTracking tracking) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Information',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing12),
          if (tracking.courierName != null) ...[
            _buildDetailRow('Delivery Partner', tracking.courierName!),
            if (tracking.courierPhone != null) _buildDetailRow('Contact', tracking.courierPhone!),
          ],
          _buildDetailRow(
            'Estimated Delivery',
            AppHelpers.formatDateTime(tracking.estimatedDelivery),
          ),
          if (tracking.courierPhone != null) ...[
            const SizedBox(height: AppConstants.spacing16),
            CustomButton(
              text: 'Contact Delivery Partner',
              onPressed: () => controller.contactCourier(tracking.courierPhone!),
              isOutlined: true,
              icon: Icons.phone,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(OrderTracking tracking) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Timeline',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing16),
          ...tracking.timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == tracking.timeline.length - 1;

            return _buildTimelineItem(event, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TrackingEvent event, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(event.status),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: AppConstants.spacing12),

        // Event details
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 0 : AppConstants.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  event.location,
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                Text(
                  AppHelpers.formatDateTime(event.timestamp),
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(OrderTracking tracking) {
    return Column(
      children: [
        if (tracking.status == OrderTrackingStatus.outForDelivery ||
            tracking.status == OrderTrackingStatus.delivered) ...[
          CustomButton(
            text: 'Share Live Location',
            onPressed: controller.shareLiveLocation,
            isOutlined: true,
            icon: Icons.location_on,
            width: double.infinity,
          ),
          const SizedBox(height: AppConstants.spacing12),
        ],
        if (tracking.status != OrderTrackingStatus.delivered && tracking.status != OrderTrackingStatus.cancelled) ...[
          CustomButton(
            text: 'Need Help?',
            onPressed: controller.getSupport,
            isOutlined: true,
            icon: Icons.help_outline,
            width: double.infinity,
          ),
        ],
      ],
    );
  }

  // Helper methods
  Color _getStatusColor(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
      case OrderTrackingStatus.confirmed:
        return Colors.blue;
      case OrderTrackingStatus.preparing:
        return Colors.orange;
      case OrderTrackingStatus.readyForPickup:
      case OrderTrackingStatus.pickedUp:
        return Colors.purple;
      case OrderTrackingStatus.outForDelivery:
        return AppConstants.primaryColor;
      case OrderTrackingStatus.delivered:
        return AppConstants.successColor;
      case OrderTrackingStatus.cancelled:
      case OrderTrackingStatus.returned:
        return AppConstants.errorColor;
    }
  }

  IconData _getStatusIcon(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return Icons.shopping_cart;
      case OrderTrackingStatus.confirmed:
        return Icons.check_circle;
      case OrderTrackingStatus.preparing:
        return Icons.kitchen;
      case OrderTrackingStatus.readyForPickup:
        return Icons.inventory_2;
      case OrderTrackingStatus.pickedUp:
        return Icons.local_shipping;
      case OrderTrackingStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderTrackingStatus.delivered:
        return Icons.home;
      case OrderTrackingStatus.cancelled:
        return Icons.cancel;
      case OrderTrackingStatus.returned:
        return Icons.keyboard_return;
    }
  }

  String _getStatusText(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return 'Order Placed';
      case OrderTrackingStatus.confirmed:
        return 'Confirmed';
      case OrderTrackingStatus.preparing:
        return 'Preparing';
      case OrderTrackingStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderTrackingStatus.pickedUp:
        return 'Picked Up';
      case OrderTrackingStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderTrackingStatus.delivered:
        return 'Delivered';
      case OrderTrackingStatus.cancelled:
        return 'Cancelled';
      case OrderTrackingStatus.returned:
        return 'Returned';
    }
  }

  String _getStatusDescription(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return 'Your order has been placed successfully';
      case OrderTrackingStatus.confirmed:
        return 'Your order has been confirmed';
      case OrderTrackingStatus.preparing:
        return 'We are preparing your order';
      case OrderTrackingStatus.readyForPickup:
        return 'Your order is ready for pickup';
      case OrderTrackingStatus.pickedUp:
        return 'Order picked up by delivery partner';
      case OrderTrackingStatus.outForDelivery:
        return 'Order is on the way to you';
      case OrderTrackingStatus.delivered:
        return 'Order delivered successfully';
      case OrderTrackingStatus.cancelled:
        return 'Order has been cancelled';
      case OrderTrackingStatus.returned:
        return 'Order has been returned';
    }
  }

  int _getCurrentStep(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return 1;
      case OrderTrackingStatus.confirmed:
        return 2;
      case OrderTrackingStatus.preparing:
        return 3;
      case OrderTrackingStatus.readyForPickup:
      case OrderTrackingStatus.pickedUp:
        return 4;
      case OrderTrackingStatus.outForDelivery:
        return 5;
      case OrderTrackingStatus.delivered:
        return 6;
      default:
        return 0;
    }
  }
}

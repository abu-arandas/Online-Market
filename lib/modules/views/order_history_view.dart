import '/exports.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = controller.filteredOrders;

              if (orders.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildOrderCard(order);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing8),
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            children: [
              _buildFilterChip('All', 'all'),
              _buildFilterChip('Preparing', 'preparing'),
              _buildFilterChip('Delivering', 'delivering'),
              _buildFilterChip('Completed', 'completed'),
              _buildFilterChip('Cancelled', 'cancelled'),
            ],
          )),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = controller.selectedStatus.value == value;

    return Container(
      margin: const EdgeInsets.only(right: AppConstants.spacing8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.changeStatusFilter(value),
        selectedColor: AppConstants.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: AppConstants.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: AppConstants.spacing8),

          // Order Date
          Text(
            AppHelpers.formatDateTime(order.orderDate),
            style: AppConstants.bodySmall.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacing12),

          // Products Count
          Text(
            '${order.items.length} item(s)',
            style: AppConstants.bodyMedium,
          ),
          const SizedBox(height: AppConstants.spacing12),

          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppConstants.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                AppHelpers.formatCurrency(order.total),
                style: AppConstants.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'View Details',
                  onPressed: () => controller.viewOrderDetails(order),
                  isOutlined: true,
                  height: 40,
                ),
              ),
              if (order.status == 'preparing' || order.status == 'confirmed') ...[
                const SizedBox(width: AppConstants.spacing8),
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () => _showCancelDialog(order),
                    backgroundColor: AppConstants.errorColor,
                    height: 40,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'preparing':
      case 'confirmed':
        color = Colors.orange;
        text = 'Preparing';
        break;
      case 'delivering':
      case 'shipped':
        color = Colors.blue;
        text = 'Delivering';
        break;
      case 'delivered':
      case 'completed':
        color = AppConstants.successColor;
        text = 'Completed';
        break;
      case 'cancelled':
        color = AppConstants.errorColor;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppConstants.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'No orders found',
            style: AppConstants.headingMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            'Your order history will appear here',
            style: AppConstants.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: AppConstants.spacing24),
          CustomButton(
            text: 'Start Shopping',
            onPressed: () => Get.offNamed(AppRoutes.home),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(OrderModel order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelOrder(order.id);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

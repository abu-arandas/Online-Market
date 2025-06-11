import '/exports.dart';

class OrderHistoryController extends GetxController {
  final OrderRepository _orderRepository = Get.find<OrderRepository>();

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      isLoading.value = true;
      final userId = Get.find<AuthController>().currentUser.value?.id ?? '';
      final ordersList = await _orderRepository.getUserOrders(userId);
      orders.value = ordersList;
    } catch (e) {
      AppHelpers.showSnackBar('Failed to load orders: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await loadOrders();
  }

  List<OrderModel> get filteredOrders {
    if (selectedStatus.value == 'all') {
      return orders;
    }

    return orders.where((order) {
      switch (selectedStatus.value) {
        case 'preparing':
          return order.status == 'preparing' || order.status == 'confirmed';
        case 'delivering':
          return order.status == 'delivering' || order.status == 'shipped';
        case 'completed':
          return order.status == 'delivered' || order.status == 'completed';
        case 'cancelled':
          return order.status == 'cancelled';
        default:
          return true;
      }
    }).toList();
  }

  void changeStatusFilter(String status) {
    selectedStatus.value = status;
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _orderRepository.updateOrderStatus(orderId, 'cancelled');
      await loadOrders();
      AppHelpers.showSnackBar('Order cancelled successfully');
    } catch (e) {
      AppHelpers.showSnackBar('Failed to cancel order: $e', isError: true);
    }
  }

  void viewOrderDetails(OrderModel order) {
    Get.toNamed(AppRoutes.orderDetails, arguments: order);
  }
}

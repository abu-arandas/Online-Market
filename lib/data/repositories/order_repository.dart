import '/exports.dart';

class OrderRepository {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Create new order
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      await _firebaseService.createDocument('orders', order.id, order.toMap());
      return order;
    } catch (e) {
      throw 'Failed to create order: $e';
    }
  }

  // Get user orders
  Future<List<OrderModel>> getUserOrders(String userId, {int limit = 20}) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'orders',
        queryBuilder: (query) =>
            query.where('userId', isEqualTo: userId).orderBy('orderDate', descending: true).limit(limit),
      );

      return querySnapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get orders: $e';
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firebaseService.getDocument('orders', orderId);

      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw 'Failed to get order: $e';
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) {
        throw 'Order not found';
      }

      final updatedOrder = order.copyWith(status: newStatus);

      await _firebaseService.updateDocument('orders', orderId, updatedOrder.toMap());
      return updatedOrder;
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  // Cancel order
  Future<OrderModel> cancelOrder(String orderId) async {
    try {
      return await updateOrderStatus(orderId, AppConstants.orderCancelled);
    } catch (e) {
      throw 'Failed to cancel order: $e';
    }
  }

  // Track order
  Future<OrderModel> trackOrder(String orderId) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) {
        throw 'Order not found';
      }
      return order;
    } catch (e) {
      throw 'Failed to track order: $e';
    }
  }

  // Listen to order updates
  Stream<OrderModel?> listenToOrder(String orderId) {
    return _firebaseService.listenToDocument('orders', orderId).map((snapshot) {
      if (snapshot.exists) {
        return OrderModel.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Listen to user orders
  Stream<List<OrderModel>> listenToUserOrders(String userId, {int limit = 20}) {
    return _firebaseService
        .listenToDocuments(
      'orders',
      queryBuilder: (query) =>
          query.where('userId', isEqualTo: userId).orderBy('orderDate', descending: true).limit(limit),
    )
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get order statistics
  Future<Map<String, int>> getOrderStatistics(String userId) async {
    try {
      final orders = await getUserOrders(userId, limit: 100);

      final stats = <String, int>{
        'total': orders.length,
        'pending': 0,
        'confirmed': 0,
        'processing': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (final order in orders) {
        stats[order.status] = (stats[order.status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw 'Failed to get order statistics: $e';
    }
  }

  // Calculate order total
  double calculateOrderTotal({
    required double subtotal,
    double deliveryFee = 0.0,
    double discount = 0.0,
    double tax = 0.0,
  }) {
    return subtotal + deliveryFee + tax - discount;
  }

  // Generate order number
  String generateOrderNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'OM$timestamp';
  }

  // Estimate delivery time
  DateTime estimateDeliveryTime({
    Duration baseDuration = const Duration(hours: 2),
    Duration additionalDuration = const Duration(minutes: 0),
  }) {
    return DateTime.now().add(baseDuration + additionalDuration);
  }
}

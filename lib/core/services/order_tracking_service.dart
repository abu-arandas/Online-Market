import '/exports.dart';

class OrderTrackingService extends GetxService {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  // Order status tracking
  final trackingData = <String, OrderTracking>{}.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _listenToOrderUpdates();
  }

  void _listenToOrderUpdates() {
    // Listen to real-time order updates from Firebase
    _firebaseService.listenToDocuments('order_tracking').listen((snapshot) {
      for (var doc in snapshot.docs) {
        final tracking = OrderTracking.fromMap(doc.data() as Map<String, dynamic>);
        trackingData[tracking.orderId] = tracking;

        // Send notification for status updates
        _sendTrackingNotification(tracking);
      }
    });
  }

  // Create order tracking
  Future<void> createOrderTracking(String orderId, String userId) async {
    try {
      final tracking = OrderTracking(
        id: orderId,
        orderId: orderId,
        userId: userId,
        status: OrderTrackingStatus.orderPlaced,
        currentLocation: 'Processing Center',
        estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
        trackingNumber: _generateTrackingNumber(),
        timeline: [
          TrackingEvent(
            status: OrderTrackingStatus.orderPlaced,
            timestamp: DateTime.now(),
            location: 'Online',
            description: 'Order placed successfully',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firebaseService.createDocument(
        'order_tracking',
        orderId,
        tracking.toMap(),
      );

      trackingData[orderId] = tracking;
    } catch (e) {
      throw 'Failed to create order tracking: $e';
    }
  }

  // Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderTrackingStatus status,
    required String location,
    String? description,
    String? courierName,
    String? courierPhone,
  }) async {
    try {
      final tracking = trackingData[orderId];
      if (tracking == null) {
        throw 'Order tracking not found';
      }

      final event = TrackingEvent(
        status: status,
        timestamp: DateTime.now(),
        location: location,
        description: description ?? _getStatusDescription(status),
        courierName: courierName,
        courierPhone: courierPhone,
      );

      final updatedTracking = tracking.copyWith(
        status: status,
        currentLocation: location,
        timeline: [...tracking.timeline, event],
        courierName: courierName,
        courierPhone: courierPhone,
        updatedAt: DateTime.now(),
      );

      await _firebaseService.updateDocument(
        'order_tracking',
        orderId,
        updatedTracking.toMap(),
      );

      trackingData[orderId] = updatedTracking;

      // Send notification
      await _sendTrackingNotification(updatedTracking);
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  // Get order tracking
  Future<OrderTracking?> getOrderTracking(String orderId) async {
    try {
      // Check cache first
      if (trackingData.containsKey(orderId)) {
        return trackingData[orderId];
      }

      // Fetch from Firebase
      final doc = await _firebaseService.getDocument('order_tracking', orderId);
      if (doc.exists) {
        final tracking = OrderTracking.fromMap(doc.data() as Map<String, dynamic>);
        trackingData[orderId] = tracking;
        return tracking;
      }

      return null;
    } catch (e) {
      throw 'Failed to get order tracking: $e';
    }
  }

  // Get user orders tracking
  Future<List<OrderTracking>> getUserOrdersTracking(String userId) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'order_tracking',
        queryBuilder: (query) => query.where('userId', isEqualTo: userId).orderBy('createdAt', descending: true),
      );

      final trackings = querySnapshot.docs.map((doc) {
        return OrderTracking.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // Update cache
      for (var tracking in trackings) {
        trackingData[tracking.orderId] = tracking;
      }

      return trackings;
    } catch (e) {
      throw 'Failed to get user orders tracking: $e';
    }
  }

  // Simulate delivery progress
  Future<void> simulateDeliveryProgress(String orderId) async {
    final statuses = [
      OrderTrackingStatus.confirmed,
      OrderTrackingStatus.preparing,
      OrderTrackingStatus.readyForPickup,
      OrderTrackingStatus.pickedUp,
      OrderTrackingStatus.outForDelivery,
      OrderTrackingStatus.delivered,
    ];

    for (var status in statuses) {
      await Future.delayed(const Duration(seconds: 30));
      await updateOrderStatus(
        orderId: orderId,
        status: status,
        location: _getLocationForStatus(status),
        description: _getStatusDescription(status),
      );
    }
  }

  // Send tracking notification
  Future<void> _sendTrackingNotification(OrderTracking tracking) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: tracking.userId,
      title: 'Order Update',
      body: 'Your order #${tracking.trackingNumber} is ${_getStatusDescription(tracking.status)}',
      type: 'order_update',
      data: {
        'orderId': tracking.orderId,
        'status': tracking.status.toString(),
      },
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _notificationService.sendNotification(notification);
  }

  // Generate tracking number
  String _generateTrackingNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString();
    return 'OM${timestamp.substring(timestamp.length - 8)}';
  }

  // Get status description
  String _getStatusDescription(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return 'Order placed successfully';
      case OrderTrackingStatus.confirmed:
        return 'Order confirmed';
      case OrderTrackingStatus.preparing:
        return 'Preparing your order';
      case OrderTrackingStatus.readyForPickup:
        return 'Ready for pickup';
      case OrderTrackingStatus.pickedUp:
        return 'Picked up by delivery partner';
      case OrderTrackingStatus.outForDelivery:
        return 'Out for delivery';
      case OrderTrackingStatus.delivered:
        return 'Delivered successfully';
      case OrderTrackingStatus.cancelled:
        return 'Order cancelled';
      case OrderTrackingStatus.returned:
        return 'Order returned';
    }
  }

  // Get location for status
  String _getLocationForStatus(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderPlaced:
        return 'Online';
      case OrderTrackingStatus.confirmed:
        return 'Processing Center';
      case OrderTrackingStatus.preparing:
        return 'Warehouse';
      case OrderTrackingStatus.readyForPickup:
        return 'Pickup Center';
      case OrderTrackingStatus.pickedUp:
        return 'In Transit';
      case OrderTrackingStatus.outForDelivery:
        return 'Local Delivery Hub';
      case OrderTrackingStatus.delivered:
        return 'Your Location';
      default:
        return 'Unknown';
    }
  }
}

// Order Tracking Models
class OrderTracking {
  final String id;
  final String orderId;
  final String userId;
  final OrderTrackingStatus status;
  final String currentLocation;
  final DateTime estimatedDelivery;
  final String trackingNumber;
  final List<TrackingEvent> timeline;
  final String? courierName;
  final String? courierPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderTracking({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.status,
    required this.currentLocation,
    required this.estimatedDelivery,
    required this.trackingNumber,
    required this.timeline,
    this.courierName,
    this.courierPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderTracking.fromMap(Map<String, dynamic> map) {
    return OrderTracking(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      status: OrderTrackingStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => OrderTrackingStatus.orderPlaced,
      ),
      currentLocation: map['currentLocation'] ?? '',
      estimatedDelivery: DateTime.fromMillisecondsSinceEpoch(map['estimatedDelivery'] ?? 0),
      trackingNumber: map['trackingNumber'] ?? '',
      timeline: (map['timeline'] as List<dynamic>? ?? [])
          .map((e) => TrackingEvent.fromMap(e as Map<String, dynamic>))
          .toList(),
      courierName: map['courierName'],
      courierPhone: map['courierPhone'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'status': status.toString(),
      'currentLocation': currentLocation,
      'estimatedDelivery': estimatedDelivery.millisecondsSinceEpoch,
      'trackingNumber': trackingNumber,
      'timeline': timeline.map((e) => e.toMap()).toList(),
      'courierName': courierName,
      'courierPhone': courierPhone,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  OrderTracking copyWith({
    String? id,
    String? orderId,
    String? userId,
    OrderTrackingStatus? status,
    String? currentLocation,
    DateTime? estimatedDelivery,
    String? trackingNumber,
    List<TrackingEvent>? timeline,
    String? courierName,
    String? courierPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderTracking(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      timeline: timeline ?? this.timeline,
      courierName: courierName ?? this.courierName,
      courierPhone: courierPhone ?? this.courierPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TrackingEvent {
  final OrderTrackingStatus status;
  final DateTime timestamp;
  final String location;
  final String description;
  final String? courierName;
  final String? courierPhone;

  TrackingEvent({
    required this.status,
    required this.timestamp,
    required this.location,
    required this.description,
    this.courierName,
    this.courierPhone,
  });

  factory TrackingEvent.fromMap(Map<String, dynamic> map) {
    return TrackingEvent(
      status: OrderTrackingStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => OrderTrackingStatus.orderPlaced,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      courierName: map['courierName'],
      courierPhone: map['courierPhone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'location': location,
      'description': description,
      'courierName': courierName,
      'courierPhone': courierPhone,
    };
  }
}

enum OrderTrackingStatus {
  orderPlaced,
  confirmed,
  preparing,
  readyForPickup,
  pickedUp,
  outForDelivery,
  delivered,
  cancelled,
  returned,
}

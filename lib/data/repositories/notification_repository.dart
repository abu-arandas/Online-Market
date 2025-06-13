import '/exports.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  Future<List<NotificationModel>> getUserNotifications(String userId, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => NotificationModel.fromMap({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<String> addNotification(NotificationModel notification) async {
    try {
      final docRef = await _firestore.collection(_collection).add(notification.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
        'readAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NotificationModel.fromMap({...doc.data(), 'id': doc.id})).toList());
  }

  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> sendOrderNotification(String userId, String orderId, String status) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'Order Update',
      body: _getOrderStatusMessage(status),
      type: 'order_update',
      data: {'orderId': orderId, 'status': status},
      createdAt: DateTime.now(),
    );

    await addNotification(notification);
  }

  Future<void> sendPromotionNotification(List<String> userIds, String title, String body, {String? imageUrl}) async {
    final batch = _firestore.batch();

    for (final userId in userIds) {
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        body: body,
        type: 'promotion',
        data: {},
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      final docRef = _firestore.collection(_collection).doc();
      batch.set(docRef, notification.toMap());
    }

    await batch.commit();
  }

  String _getOrderStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Your order has been confirmed and is being prepared.';
      case 'preparing':
        return 'Your order is being prepared for delivery.';
      case 'out_for_delivery':
        return 'Your order is out for delivery!';
      case 'delivered':
        return 'Your order has been delivered successfully.';
      case 'cancelled':
        return 'Your order has been cancelled.';
      default:
        return 'Your order status has been updated.';
    }
  }
}

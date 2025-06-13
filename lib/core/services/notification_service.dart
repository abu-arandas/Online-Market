import '/exports.dart';

enum NotificationType {
  order,
  promotion,
  general,
  reminder,
  system,
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static NotificationService get to => Get.find();

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
    await _requestPermissions();
    _setupMessageHandlers();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> requestPermissions() => _requestPermissions();

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp
        .listen(_handleMessageOpenedApp); // Handle messages when app is opened from terminated state
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('route')) {
      Get.toNamed(data['route']);
    } else if (data.containsKey('orderId')) {
      Get.toNamed('/order-details', arguments: data['orderId']);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      // Handle local notification tap
      print('Notification tapped: ${response.payload}');
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  Future<void> scheduleOrderReminder(String orderId, DateTime deliveryTime) async {
    final scheduledTime = deliveryTime.subtract(const Duration(hours: 1));

    if (scheduledTime.isAfter(DateTime.now())) {
      // Note: For scheduled notifications, you might want to use a different plugin
      // like flutter_local_notifications with scheduling capabilities
      await showLocalNotification(
        title: 'Order Reminder',
        body: 'Your order will be delivered in 1 hour!',
        payload: 'order_reminder:$orderId',
      );
    }
  }

  Future<void> sendAbandonedCartNotification(String userId) async {
    await Future.delayed(const Duration(hours: 24)); // Simulate delay

    await showLocalNotification(
      title: 'Don\'t forget your cart! 🛒',
      body: 'You have items waiting for you. Complete your purchase now!',
      payload: 'abandoned_cart:$userId',
    );
  }

  // Send notification with type
  Future<void> sendNotification(NotificationModel notification) async {
    await showLocalNotification(
      title: notification.title,
      body: notification.body,
      payload: notification.data.toString(),
    );
  }

  // Send notification with parameters
  Future<void> sendNotificationWithParams({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    await showLocalNotification(
      title: title,
      body: body,
      payload: data?.toString() ?? '',
    );
  }
}

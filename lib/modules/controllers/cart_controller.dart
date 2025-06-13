import '/exports.dart';

class CartController extends GetxController {
  final CartRepository _cartRepository = CartRepository();
  final OrderRepository _orderRepository = OrderRepository();

  // Observables
  final Rx<CartModel?> cart = Rx<CartModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxDouble deliveryFee = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxString discountCode = ''.obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);
  final RxString paymentMethod = AppConstants.paymentCash.obs;

  // Controllers
  final discountController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeCart();
  }

  @override
  void onClose() {
    discountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // Initialize cart
  Future<void> _initializeCart() async {
    final authController = Get.find<AuthController>();
    if (authController.isLoggedIn.value) {
      await loadCart();
    }
  }

  // Load user cart
  Future<void> loadCart() async {
    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId != null) {
        final userCart = await _cartRepository.getUserCart(userId);
        cart.value = userCart;
        _calculateDeliveryFee();
      }
    } catch (e) {
      // Cart loading errors are handled silently
    }
  }

  // Add item to cart
  Future<void> addItemToCart(ProductModel product, {int quantity = 1}) async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId == null) {
        AppHelpers.showSnackBar('Please login to add items to cart', isError: true);
        return;
      }
      final cartItem = CartItemModel.fromProduct(product, quantity: quantity);
      final updatedCart = await _cartRepository.addItemToCart(userId, cartItem);
      cart.value = updatedCart;

      _calculateDeliveryFee();
      AppHelpers.showSnackBar(AppConstants.itemAddedToCart);
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Alias method for addItemToCart to support both interfaces
  Future<void> addToCart(ProductModel product, [int quantity = 1]) async {
    await addItemToCart(product, quantity: quantity);
  }

  // Remove item from cart
  Future<void> removeItemFromCart(String productId) async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId != null) {
        final updatedCart = await _cartRepository.removeItemFromCart(userId, productId);
        cart.value = updatedCart;

        _calculateDeliveryFee();
        AppHelpers.showSnackBar(AppConstants.itemRemovedFromCart);
      }
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Update item quantity
  Future<void> updateItemQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItemFromCart(productId);
      return;
    }

    try {
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId != null) {
        final updatedCart = await _cartRepository.updateItemQuantity(
          userId,
          productId,
          quantity,
        );
        cart.value = updatedCart;
        _calculateDeliveryFee();
      }
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      isLoading.value = true;

      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.id;

      if (userId != null) {
        cart.value = null;
        deliveryFee.value = 0.0;
        discount.value = 0.0;
      }
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Apply discount code
  Future<void> applyDiscountCode() async {
    try {
      final code = discountController.text.trim();
      if (code.isEmpty) return;

      final discountAmount = await _cartRepository.applyDiscountCode(
        code,
        cartSubtotal,
      );

      if (discountAmount > 0) {
        discount.value = discountAmount;
        discountCode.value = code;
        AppHelpers.showSnackBar('Discount applied successfully!');
      } else {
        AppHelpers.showSnackBar('Invalid discount code', isError: true);
      }
    } catch (e) {
      AppHelpers.showSnackBar('Failed to apply discount', isError: true);
    }
  }

  // Remove discount
  void removeDiscount() {
    discount.value = 0.0;
    discountCode.value = '';
    discountController.clear();
    AppHelpers.showSnackBar('Discount removed');
  }

  // Calculate delivery fee
  Future<void> _calculateDeliveryFee() async {
    try {
      if (cart.value == null || cart.value!.isEmpty) {
        deliveryFee.value = 0.0;
        return;
      }

      final authController = Get.find<AuthController>();
      final user = authController.currentUser.value;

      if (user != null && user.addresses.isNotEmpty) {
        final address = selectedAddress.value ?? user.addresses.first;
        final fee = await _cartRepository.calculateDeliveryFee(
          cart.value!,
          address.latitude,
          address.longitude,
        );
        deliveryFee.value = fee;
      }
    } catch (e) {
      deliveryFee.value = 5.0; // Default delivery fee
    }
  }

  // Select delivery address
  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
    _calculateDeliveryFee();
  }

  // Select payment method
  void selectPaymentMethod(String method) {
    paymentMethod.value = method;
  }

  // Checkout
  Future<void> checkout() async {
    try {
      isCheckingOut.value = true;

      // Validate checkout requirements
      if (cart.value == null || cart.value!.isEmpty) {
        AppHelpers.showSnackBar('Cart is empty', isError: true);
        return;
      }

      if (selectedAddress.value == null) {
        AppHelpers.showSnackBar('Please select delivery address', isError: true);
        return;
      }

      // Create order
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value!.id;

      final orderItems = cart.value!.items.map((item) => OrderItemModel.fromCartItem(item)).toList();

      final order = OrderModel(
        id: _orderRepository.generateOrderNumber(),
        userId: userId,
        items: orderItems,
        deliveryAddress: selectedAddress.value!,
        paymentMethod: paymentMethod.value,
        status: AppConstants.orderPending,
        subtotal: cartSubtotal,
        deliveryFee: deliveryFee.value,
        discount: discount.value,
        total: cartTotal,
        orderDate: DateTime.now(),
        estimatedDelivery: _orderRepository.estimateDeliveryTime(),
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      );

      await _orderRepository.createOrder(order);

      // Clear cart after successful order
      await clearCart();

      AppHelpers.showSnackBar(AppConstants.orderPlaced);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isCheckingOut.value = false;
    }
  }

  // Computed properties
  double get cartSubtotal => cart.value?.totalPrice ?? 0.0;

  int get cartItemCount => cart.value?.totalItems ?? 0;

  double get cartTotal => cartSubtotal + deliveryFee.value - discount.value;

  bool get isEmpty => cart.value?.isEmpty ?? true;

  bool get isNotEmpty => !isEmpty;

  List<CartItemModel> get cartItems => cart.value?.items ?? [];

  // Navigation methods
  void goToCheckout() {
    if (isEmpty) {
      AppHelpers.showSnackBar('Cart is empty', isError: true);
      return;
    }
    Get.toNamed(AppRoutes.checkout);
  }

  void goToAddAddress() {
    Get.toNamed(AppRoutes.addAddress);
  }

  void goToAddresses() {
    Get.toNamed(AppRoutes.addresses);
  }

  // Helper methods
  String formatPrice(double price) {
    return AppHelpers.formatCurrency(price);
  }

  bool hasDiscount() {
    return discount.value > 0;
  }

  String get deliveryFeeText {
    return deliveryFee.value == 0 ? 'Free' : formatPrice(deliveryFee.value);
  }

  // Get available payment methods
  List<Map<String, dynamic>> get paymentMethods {
    return [
      {
        'id': AppConstants.paymentCash,
        'name': 'Cash on Delivery',
        'icon': Icons.money,
      },
      {
        'id': AppConstants.paymentCard,
        'name': 'Credit/Debit Card',
        'icon': Icons.credit_card,
      },
      {
        'id': AppConstants.paymentWallet,
        'name': 'Digital Wallet',
        'icon': Icons.account_balance_wallet,
      },
    ];
  }
}

import '/exports.dart';

class CartRepository {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final GetStorage _storage = Get.find<GetStorage>();

  // Get user's cart
  Future<CartModel?> getUserCart(String userId) async {
    try {
      final doc = await _firebaseService.getDocument('carts', userId);

      if (doc.exists) {
        return CartModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      // Try to get from local storage
      return _getCartFromStorage();
    } catch (e) {
      // Fallback to local storage
      return _getCartFromStorage();
    }
  }

  // Save cart
  Future<CartModel> saveCart(CartModel cart) async {
    try {
      await _firebaseService.createDocument('carts', cart.userId, cart.toMap());
      await _saveCartToStorage(cart);
      return cart;
    } catch (e) {
      // Save to local storage if Firebase fails
      await _saveCartToStorage(cart);
      return cart;
    }
  }

  // Update cart
  Future<CartModel> updateCart(CartModel cart) async {
    try {
      final updatedCart = cart.copyWith(updatedAt: DateTime.now());
      await _firebaseService.updateDocument('carts', cart.userId, updatedCart.toMap());
      await _saveCartToStorage(updatedCart);
      return updatedCart;
    } catch (e) {
      // Save to local storage if Firebase fails
      await _saveCartToStorage(cart);
      return cart;
    }
  }

  // Add item to cart
  Future<CartModel> addItemToCart(String userId, CartItemModel item) async {
    try {
      CartModel? cart = await getUserCart(userId);

      if (cart == null) {
        // Create new cart
        cart = CartModel(
          id: userId,
          userId: userId,
          items: [item],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        // Check if item already exists
        final existingItemIndex = cart.items.indexWhere(
          (existingItem) => existingItem.productId == item.productId,
        );

        List<CartItemModel> updatedItems = List.from(cart.items);

        if (existingItemIndex != -1) {
          // Update existing item quantity
          final existingItem = updatedItems[existingItemIndex];
          updatedItems[existingItemIndex] = existingItem.copyWith(
            quantity: existingItem.quantity + item.quantity,
          );
        } else {
          // Add new item
          updatedItems.add(item);
        }

        cart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );
      }

      return await updateCart(cart);
    } catch (e) {
      throw 'Failed to add item to cart: $e';
    }
  }

  // Remove item from cart
  Future<CartModel> removeItemFromCart(String userId, String productId) async {
    try {
      CartModel? cart = await getUserCart(userId);

      if (cart != null) {
        final updatedItems = cart.items
            .where(
              (item) => item.productId != productId,
            )
            .toList();

        cart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        return await updateCart(cart);
      }

      throw 'Cart not found';
    } catch (e) {
      throw 'Failed to remove item from cart: $e';
    }
  }

  // Update item quantity
  Future<CartModel> updateItemQuantity(String userId, String productId, int quantity) async {
    try {
      CartModel? cart = await getUserCart(userId);

      if (cart != null) {
        final updatedItems = cart.items.map((item) {
          if (item.productId == productId) {
            return item.copyWith(quantity: quantity);
          }
          return item;
        }).toList();

        cart = cart.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        return await updateCart(cart);
      }

      throw 'Cart not found';
    } catch (e) {
      throw 'Failed to update item quantity: $e';
    }
  }

  // Clear cart
  Future<void> clearCart(String userId) async {
    try {
      await _firebaseService.deleteDocument('carts', userId);
      await _clearCartFromStorage();
    } catch (e) {
      await _clearCartFromStorage();
    }
  }

  // Listen to cart changes
  Stream<CartModel?> listenToCart(String userId) {
    try {
      return _firebaseService.listenToDocument('carts', userId).map((snapshot) {
        if (snapshot.exists) {
          final cart = CartModel.fromMap(snapshot.data() as Map<String, dynamic>);
          _saveCartToStorage(cart);
          return cart;
        }
        return null;
      });
    } catch (e) {
      // Return stream with local cart
      return Stream.value(_getCartFromStorage());
    }
  }

  // Sync local cart with server
  Future<void> syncCart(String userId) async {
    try {
      final localCart = _getCartFromStorage();
      if (localCart != null && localCart.userId == userId) {
        await saveCart(localCart);
      }
    } catch (e) {
      // Ignore sync errors
    }
  }

  // Private methods for local storage
  Future<void> _saveCartToStorage(CartModel cart) async {
    await _storage.write(Config.cartDataKey, cart.toMap());
  }

  Future<void> _clearCartFromStorage() async {
    await _storage.remove(Config.cartDataKey);
  }

  CartModel? _getCartFromStorage() {
    final cartData = _storage.read(Config.cartDataKey);
    if (cartData != null) {
      return CartModel.fromMap(Map<String, dynamic>.from(cartData));
    }
    return null;
  }

  // Calculate delivery fee based on cart and location
  Future<double> calculateDeliveryFee(CartModel cart, double userLatitude, double userLongitude) async {
    try {
      final mappingService = Get.find<MappingService>();

      // Calculate distance from store to user
      const storeLatitude = 31.9539; // Store location (example: Amman, Jordan)
      const storeLongitude = 35.9106;

      final distance = mappingService.calculateDistance(
        storeLatitude,
        storeLongitude,
        userLatitude,
        userLongitude,
      );

      return mappingService.calculateDeliveryFee(distance);
    } catch (e) {
      return 5.0; // Default delivery fee
    }
  }

  // Apply discount code
  Future<double> applyDiscountCode(String discountCode, double cartTotal) async {
    try {
      // In a real app, you would validate the discount code against a database
      // For now, provide some sample discount codes
      switch (discountCode.toUpperCase()) {
        case 'SAVE10':
          return cartTotal * 0.1; // 10% discount
        case 'SAVE20':
          return cartTotal * 0.2; // 20% discount
        case 'WELCOME':
          return 5.0; // $5 off
        default:
          return 0.0; // No discount
      }
    } catch (e) {
      return 0.0;
    }
  }
}

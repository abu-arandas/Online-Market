import '/exports.dart';

class CartRepository {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Get user's cart
  Future<CartModel?> getUserCart(String userId) async {}

  // Save cart
  Future<CartModel> saveCart(CartModel cart) async {
    try {
      await _firebaseService.createDocument('carts', cart.userId, cart.toMap());
      return cart;
    } catch (e) {
      // Save to local storage if Firebase fails
      return cart;
    }
  }

  // Update cart
  Future<CartModel> updateCart(CartModel cart) async {
    try {
      final updatedCart = cart.copyWith(updatedAt: DateTime.now());
      await _firebaseService.updateDocument('carts', cart.userId, updatedCart.toMap());
      return updatedCart;
    } catch (e) {
      // Save to local storage if Firebase fails
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

  // Sync local cart with server
  Future<void> syncCart(String userId) async {}

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

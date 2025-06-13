import '/exports.dart';

class WishlistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'wishlists';

  Future<WishlistModel?> getUserWishlist(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return WishlistModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get wishlist: $e');
    }
  }

  Future<void> createWishlist(WishlistModel wishlist) async {
    try {
      await _firestore.collection(_collection).doc(wishlist.userId).set(wishlist.toMap());
    } catch (e) {
      throw Exception('Failed to create wishlist: $e');
    }
  }

  Future<void> updateWishlist(WishlistModel wishlist) async {
    try {
      await _firestore.collection(_collection).doc(wishlist.userId).update(wishlist.toMap());
    } catch (e) {
      throw Exception('Failed to update wishlist: $e');
    }
  }

  Future<void> addToWishlist(String userId, String productId) async {
    try {
      final wishlist = await getUserWishlist(userId);
      if (wishlist != null) {
        final updatedWishlist = wishlist.addProduct(productId);
        await updateWishlist(updatedWishlist);
      } else {
        final newWishlist = WishlistModel(
          id: userId,
          userId: userId,
          productIds: [productId],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await createWishlist(newWishlist);
      }
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      final wishlist = await getUserWishlist(userId);
      if (wishlist != null) {
        final updatedWishlist = wishlist.removeProduct(productId);
        await updateWishlist(updatedWishlist);
      }
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  Future<bool> isInWishlist(String userId, String productId) async {
    try {
      final wishlist = await getUserWishlist(userId);
      return wishlist?.containsProduct(productId) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Alias for backwards compatibility
  Future<bool> isProductInWishlist(String userId, String productId) async {
    return isInWishlist(userId, productId);
  }

  Stream<WishlistModel?> watchUserWishlist(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return WishlistModel.fromMap(doc.data()!);
      }
      return null;
    });
  }
}

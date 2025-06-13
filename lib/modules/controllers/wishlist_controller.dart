import '/exports.dart';

class WishlistController extends GetxController {
  final WishlistRepository _wishlistRepository = Get.find<WishlistRepository>();
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final wishlist = Rxn<WishlistModel>();
  final wishlistProducts = <ProductModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    if (_authController.currentUser.value == null) return;

    try {
      isLoading.value = true;
      final userId = _authController.currentUser.value!.id;

      // Watch wishlist changes
      _wishlistRepository.watchUserWishlist(userId).listen((userWishlist) {
        wishlist.value = userWishlist;
        if (userWishlist != null) {
          _loadWishlistProducts(userWishlist.productIds);
        } else {
          wishlistProducts.clear();
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load wishlist: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadWishlistProducts(List<String> productIds) async {
    if (productIds.isEmpty) {
      wishlistProducts.clear();
      return;
    }

    try {
      final ProductRepository productRepository = Get.find<ProductRepository>();
      final products = <ProductModel>[];

      for (final productId in productIds) {
        final product = await productRepository.getProduct(productId);
        if (product != null) {
          products.add(product);
        }
      }

      wishlistProducts.value = products;
    } catch (e) {
      print('Error loading wishlist products: $e');
    }
  }

  Future<void> addToWishlist(ProductModel product) async {
    if (_authController.currentUser.value == null) {
      Get.toNamed('/login');
      return;
    }

    try {
      final userId = _authController.currentUser.value!.id;
      await _wishlistRepository.addToWishlist(userId, product.id);

      Get.snackbar(
        'Added to Wishlist',
        '${product.name} has been added to your wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add to wishlist: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> removeFromWishlist(ProductModel product) async {
    if (_authController.currentUser.value == null) return;

    try {
      final userId = _authController.currentUser.value!.id;
      await _wishlistRepository.removeFromWishlist(userId, product.id);

      Get.snackbar(
        'Removed from Wishlist',
        '${product.name} has been removed from your wishlist',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove from wishlist: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool isInWishlist(String productId) {
    return wishlist.value?.containsProduct(productId) ?? false;
  }

  Future<void> toggleWishlist(ProductModel product) async {
    if (isInWishlist(product.id)) {
      await removeFromWishlist(product);
    } else {
      await addToWishlist(product);
    }
  }

  Future<void> addAllToCart() async {
    if (wishlistProducts.isEmpty) return;

    try {
      final CartController cartController = Get.find<CartController>();
      int addedCount = 0;

      for (final product in wishlistProducts) {
        if (product.isAvailable && product.stockQuantity > 0) {
          await cartController.addToCart(product, 1);
          addedCount++;
        }
      }

      if (addedCount > 0) {
        Get.snackbar(
          'Added to Cart',
          '$addedCount items added to cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add items to cart: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> clearWishlist() async {
    if (_authController.currentUser.value == null || wishlistProducts.isEmpty) return;

    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Clear Wishlist'),
          content: const Text('Are you sure you want to remove all items from your wishlist?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Clear'),
            ),
          ],
        ),
      );

      if (result == true) {
        final userId = _authController.currentUser.value!.id;
        final emptyWishlist = WishlistModel(
          id: userId,
          userId: userId,
          productIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _wishlistRepository.updateWishlist(emptyWishlist);

        Get.snackbar(
          'Wishlist Cleared',
          'All items have been removed from your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear wishlist: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void navigateToProduct(ProductModel product) {
    Get.toNamed('/product-details', arguments: product);
  }

  int get itemCount => wishlist.value?.productIds.length ?? 0;

  bool get isEmpty => itemCount == 0;

  bool get isNotEmpty => itemCount > 0;
}

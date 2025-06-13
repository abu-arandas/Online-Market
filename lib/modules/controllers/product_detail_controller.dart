import '/exports.dart';

class ProductDetailController extends GetxController {
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final ReviewRepository _reviewRepository = Get.find<ReviewRepository>();
  final WishlistRepository _wishlistRepository = Get.find<WishlistRepository>();
  final CartController _cartController = Get.find<CartController>();
  final AuthController _authController = Get.find<AuthController>();
  final ARService _arService = Get.find<ARService>();

  // Reactive variables
  final product = Rxn<ProductModel>();
  final reviews = <ReviewModel>[].obs;
  final relatedProducts = <ProductModel>[].obs;
  final quantity = 1.obs;
  final currentImageIndex = 0.obs;
  final isLoading = false.obs;
  final isLoadingReviews = false.obs;
  final isDescriptionExpanded = false.obs;
  final isWishlisted = false.obs;

  // Controllers
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _initializeProduct();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _initializeProduct() {
    final productArg = Get.arguments;
    if (productArg is ProductModel) {
      product.value = productArg;
      _loadProductDetails();
      _loadReviews();
      _loadRelatedProducts();
      _checkWishlistStatus();
    } else if (productArg is String) {
      _loadProductById(productArg);
    }
  }

  Future<void> _loadProductById(String productId) async {
    try {
      isLoading.value = true;
      final productData = await _productRepository.getProductById(productId);
      if (productData != null) {
        product.value = productData;
        _loadReviews();
        _loadRelatedProducts();
        _checkWishlistStatus();
      } else {
        AppHelpers.showSnackBar('Product not found', isError: true);
        Get.back();
      }
    } catch (e) {
      AppHelpers.showSnackBar('Failed to load product', isError: true);
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProductDetails() async {
    if (product.value == null) return;

    try {
      // Refresh product data from server
      final updatedProduct = await _productRepository.getProductById(product.value!.id);
      if (updatedProduct != null) {
        product.value = updatedProduct;
      }
    } catch (e) {
      // Silently handle error, use cached data
    }
  }

  Future<void> _loadReviews() async {
    if (product.value == null) return;

    try {
      isLoadingReviews.value = true;
      final productReviews = await _reviewRepository.getProductReviews(
        product.value!.id,
        limit: 5,
      );
      reviews.value = productReviews;
    } catch (e) {
      // Silently handle error
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> _loadRelatedProducts() async {
    if (product.value == null) return;

    try {
      final related = await _productRepository.getProductsByCategory(
        product.value!.category,
        limit: 10,
      );

      // Remove current product from related products
      relatedProducts.value = related.where((p) => p.id != product.value!.id).take(5).toList();
    } catch (e) {
      // Silently handle error
    }
  }

  Future<void> _checkWishlistStatus() async {
    if (product.value == null || !_authController.isLoggedIn.value) return;

    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      final wishlisted = await _wishlistRepository.isProductInWishlist(
        user.id,
        product.value!.id,
      );
      isWishlisted.value = wishlisted;
    } catch (e) {
      // Silently handle error
    }
  }

  // Image gallery methods
  void updateCurrentImageIndex(int index) {
    currentImageIndex.value = index;
  }

  // Quantity methods
  void increaseQuantity() {
    if (product.value != null && quantity.value < product.value!.stockQuantity) {
      quantity.value++;
    }
  }

  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  // Description methods
  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  // Wishlist methods
  Future<void> toggleWishlist() async {
    if (product.value == null || !_authController.isLoggedIn.value) {
      AppHelpers.showSnackBar('Please log in to manage wishlist', isError: true);
      Get.toNamed(AppRoutes.login);
      return;
    }

    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      final userId = user.id;
      final productId = product.value!.id;

      if (isWishlisted.value) {
        await _wishlistRepository.removeFromWishlist(userId, productId);
        isWishlisted.value = false;
        AppHelpers.showSnackBar('Removed from wishlist');
      } else {
        await _wishlistRepository.addToWishlist(userId, productId);
        isWishlisted.value = true;
        AppHelpers.showSnackBar('Added to wishlist');
      }
    } catch (e) {
      AppHelpers.showSnackBar('Failed to update wishlist', isError: true);
    }
  }

  // Cart methods
  Future<void> addToCart() async {
    if (product.value == null) return;

    if (!product.value!.isInStock) {
      AppHelpers.showSnackBar('Product is out of stock', isError: true);
      return;
    }
    try {
      await _cartController.addToCart(product.value!, quantity.value);
      AppHelpers.showSnackBar('Added to cart successfully');
    } catch (e) {
      AppHelpers.showSnackBar('Failed to add to cart', isError: true);
    }
  }

  Future<void> buyNow() async {
    if (product.value == null) return;

    if (!product.value!.isInStock) {
      AppHelpers.showSnackBar('Product is out of stock', isError: true);
      return;
    }
    try {
      await _cartController.addToCart(product.value!, quantity.value);
      Get.toNamed(AppRoutes.cart);
    } catch (e) {
      AppHelpers.showSnackBar('Failed to proceed to cart', isError: true);
    }
  }

  // Review methods
  void writeReview() {
    if (!_authController.isLoggedIn.value) {
      AppHelpers.showSnackBar('Please log in to write a review', isError: true);
      Get.toNamed(AppRoutes.login);
      return;
    }

    Get.toNamed(
      AppRoutes.writeReview,
      arguments: {
        'productId': product.value!.id,
        'productName': product.value!.name,
      },
    );
  }

  void goToAllReviews() {
    Get.toNamed(
      AppRoutes.productReviews,
      arguments: {
        'productId': product.value!.id,
        'productName': product.value!.name,
      },
    );
  }

  // Navigation methods
  void goToProduct(ProductModel product) {
    Get.offNamed(
      AppRoutes.productDetails,
      arguments: product,
    );
  }

  // Share methods
  void shareProduct() {
    if (product.value == null) return;

    final shareText = '''
Check out this amazing product: ${product.value!.name}

${product.value!.description}

Price: ${AppHelpers.formatCurrency(product.value!.effectivePrice)}

Download our app to order now!
''';

    Share.share(shareText);
  }

  // Refresh methods
  Future<void> refreshProduct() async {
    await _loadProductDetails();
    await _loadReviews();
    await _loadRelatedProducts();
    await _checkWishlistStatus();
  }

  // AR Methods
  Future<void> previewInAR() async {
    if (product.value == null) return;

    try {
      await _arService.startARPreview(product.value!);
    } catch (e) {
      Get.snackbar(
        'AR Error',
        'Failed to start AR preview: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void captureARScreenshot() async {
    await _arService.captureARScreenshot();
  }

  void shareARExperience() async {
    if (product.value == null) return;
    await _arService.shareARExperience(product.value!);
  }

  bool get isARSupported => _arService.isARSupported.value;
  bool get isARActive => _arService.isARActive.value;
}

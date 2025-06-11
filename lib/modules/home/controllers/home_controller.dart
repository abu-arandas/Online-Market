import '/exports.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();

  // Observables
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> searchResults = <ProductModel>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentCarouselIndex = 0.obs;

  // Controllers
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  // Carousel images for featured deals
  final RxList<String> carouselImages = <String>[
    'assets/images/offer.png',
    'assets/images/online_groceries.png',
    'assets/images/Spline.png',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeHome();
    _setupScrollListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Initialize home data
  Future<void> _initializeHome() async {
    await loadCategories();
    await loadFeaturedProducts();
    await loadAllProducts();
  }

  // Setup scroll listener for pagination
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        // Load more products when reached bottom
        loadMoreProducts();
      }
    });
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final categoryList = await _productRepository.getProductCategories();
      categories.value = categoryList;
    } catch (e) {
      AppHelpers.showSnackBar('Failed to load categories', isError: true);
    }
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    try {
      isLoading.value = true;
      final products = await _productRepository.getFeaturedProducts(limit: 10);
      featuredProducts.value = products;
    } catch (e) {
      AppHelpers.showSnackBar('Failed to load featured products', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Load all products
  Future<void> loadAllProducts() async {
    try {
      isLoading.value = true;
      final products = await _productRepository.getAllProducts(limit: 20);
      allProducts.value = products;
    } catch (e) {
      AppHelpers.showSnackBar('Failed to load products', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    try {
      if (selectedCategory.isEmpty) {
        final products = await _productRepository.getAllProducts(limit: 10);
        allProducts.addAll(products);
      } else {
        final products = await _productRepository.getProductsByCategory(
          selectedCategory.value,
          limit: 10,
        );
        allProducts.addAll(products);
      }
    } catch (e) {
      // Silently handle pagination errors
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    try {
      isSearching.value = true;
      searchQuery.value = query;

      final products = await _productRepository.searchProducts(query, limit: 20);
      searchResults.value = products;
    } catch (e) {
      AppHelpers.showSnackBar('Search failed', isError: true);
    } finally {
      isSearching.value = false;
    }
  }

  // Filter products by category
  Future<void> filterByCategory(String category) async {
    try {
      isLoading.value = true;
      selectedCategory.value = category;

      if (category.isEmpty) {
        await loadAllProducts();
      } else {
        final products = await _productRepository.getProductsByCategory(
          category,
          limit: 20,
        );
        allProducts.value = products;
      }
    } catch (e) {
      AppHelpers.showSnackBar('Failed to filter products', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([
      loadFeaturedProducts(),
      loadAllProducts(),
    ]);
  }

  // Update carousel index
  void updateCarouselIndex(int index) {
    currentCarouselIndex.value = index;
  }

  // Add product to cart
  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    try {
      final cartController = Get.find<CartController>();
      await cartController.addItemToCart(product, quantity: quantity);
      AppHelpers.showSnackBar(AppConstants.itemAddedToCart);
    } catch (e) {
      AppHelpers.showSnackBar('Failed to add to cart', isError: true);
    }
  }

  // Scan barcode
  Future<void> scanBarcode() async {
    try {
      final scanningService = Get.find<ScanningService>();
      final barcode = await scanningService.scanBarcode();

      if (barcode != null) {
        final product = await scanningService.searchProductByBarcode(barcode);
        if (product != null) {
          // Navigate to product details or add to cart
          AppHelpers.showSnackBar('Product found: ${product.name}');
          await addToCart(product);
        } else {
          AppHelpers.showSnackBar('Product not found', isError: true);
        }
      }
    } catch (e) {
      AppHelpers.showSnackBar('Scan failed', isError: true);
    }
  }

  // Navigation methods
  void goToProductDetails(ProductModel product) {
    Get.toNamed(AppRoutes.productDetails, arguments: product);
  }

  void goToCategory(String category) {
    Get.toNamed(AppRoutes.categoryProducts, arguments: category);
  }

  void goToCart() {
    Get.toNamed(AppRoutes.cart);
  }

  void goToProfile() {
    Get.toNamed(AppRoutes.profile);
  }

  // Get greeting message
  String get greetingMessage {
    final authController = Get.find<AuthController>();
    final userName = authController.currentUser.value?.name ?? 'User';
    return '${AppHelpers.getGreeting()}, $userName!';
  }

  // Get products to display based on search/filter state
  List<ProductModel> get displayedProducts {
    if (searchQuery.isNotEmpty && searchResults.isNotEmpty) {
      return searchResults;
    }
    return allProducts;
  }

  // Check if there are any products to display
  bool get hasProducts {
    return displayedProducts.isNotEmpty;
  }

  // Get current page title
  String get pageTitle {
    if (searchQuery.isNotEmpty) {
      return 'Search Results for "${searchQuery.value}"';
    }
    if (selectedCategory.isNotEmpty) {
      return selectedCategory.value;
    }
    return 'All Products';
  }
}

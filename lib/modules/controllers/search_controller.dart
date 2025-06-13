import '/exports.dart';

class SearchController extends GetxController {
  final SearchService _searchService = Get.find<SearchService>();
  final VoiceSearchService _voiceSearchService = Get.find<VoiceSearchService>();

  // Observable variables
  final searchQuery = ''.obs;
  final searchResults = <ProductModel>[].obs;
  final isLoading = false.obs;
  final suggestions = <String>[].obs;
  final searchHistory = <String>[].obs;
  final categories = <String>[].obs;
  final popularSearches = <String>[].obs;

  // Voice search variables
  final isListening = false.obs;
  final voiceSearchError = Rxn<String>();

  // Filter variables
  final selectedCategory = Rxn<String>();
  final minPrice = Rxn<double>();
  final maxPrice = Rxn<double>();
  final minRating = Rxn<double>();
  final inStockOnly = false.obs;
  final sortBy = 'relevance'.obs;

  // Filter options
  final filterOptions = <String, dynamic>{}.obs;

  final TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    try {
      // Load categories and filter options
      final filters = await _searchService.getSearchFilters();
      filterOptions.value = filters;

      if (filters['categories'] != null) {
        categories.value = List<String>.from(filters['categories']);
      }

      // Load popular searches
      final popular = await _searchService.getPopularSearchTerms();
      popularSearches.value = popular;
    } catch (e) {
      print('Error loading initial search data: $e');
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      searchQuery.value = query;

      final results = await _searchService.searchProducts(
        query: query,
        category: selectedCategory.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        minRating: minRating.value,
        inStock: inStockOnly.value,
        sortBy: sortBy.value,
      );

      searchResults.value = results;
    } catch (e) {
      Get.snackbar(
        'Search Error',
        'Failed to search products: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectSuggestion(String suggestion) {
    searchTextController.text = suggestion;
    search(suggestion);
    suggestions.clear();
  }

  void searchFromHistory(String query) {
    searchTextController.text = query;
    search(query);
  }

  void clearSearch() {
    searchQuery.value = '';
    searchTextController.clear();
    searchResults.clear();
    suggestions.clear();
  }

  void setCategory(String? category) {
    selectedCategory.value = category;
    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  void setPriceRange(double? min, double? max) {
    minPrice.value = min;
    maxPrice.value = max;
    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  void setMinRating(double? rating) {
    minRating.value = rating;
    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  void toggleInStockOnly() {
    inStockOnly.value = !inStockOnly.value;
    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  void clearFilters() {
    selectedCategory.value = null;
    minPrice.value = null;
    maxPrice.value = null;
    minRating.value = null;
    inStockOnly.value = false;
    sortBy.value = 'relevance';

    if (searchQuery.value.isNotEmpty) {
      search(searchQuery.value);
    }
  }

  bool get hasActiveFilters {
    return selectedCategory.value != null ||
        minPrice.value != null ||
        maxPrice.value != null ||
        minRating.value != null ||
        inStockOnly.value ||
        sortBy.value != 'relevance';
  }

  void navigateToProduct(ProductModel product) {
    Get.toNamed('/product-details', arguments: product);
  }

  // Voice search methods
  Future<void> toggleVoiceSearch() async {
    if (isListening.value) {
      await _stopVoiceSearch();
    } else {
      await _startVoiceSearch();
    }
  }

  Future<void> _startVoiceSearch() async {
    try {
      isListening.value = true;
      voiceSearchError.value = null;

      final result = await _voiceSearchService.startVoiceSearch();
      if (result != null && result.isNotEmpty) {
        searchTextController.text = result;
        await search(result);
      }
    } catch (e) {
      voiceSearchError.value = e.toString();
      Get.snackbar(
        'Voice Search Error',
        'Failed to process voice search: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      isListening.value = false;
    }
  }

  Future<void> _stopVoiceSearch() async {
    try {
      await _voiceSearchService.stopVoiceSearch();
    } catch (e) {
      print('Error stopping voice search: $e');
    } finally {
      isListening.value = false;
    }
  }
}

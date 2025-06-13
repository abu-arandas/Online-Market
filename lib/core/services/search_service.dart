import '/exports.dart';

class SearchService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cacheService = Get.find<CacheService>();

  static SearchService get to => Get.find();

  Future<List<ProductModel>> searchProducts({
    required String query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? inStock,
    String sortBy = 'relevance', // relevance, price_low, price_high, rating, newest
  }) async {
    try {
      // Save search query to history
      if (query.isNotEmpty) {
        await _cacheService.addSearchQuery(query);
      }

      Query queryRef = _firestore.collection('products');

      // Apply filters
      if (category != null && category.isNotEmpty) {
        queryRef = queryRef.where('category', isEqualTo: category);
      }

      if (minPrice != null) {
        queryRef = queryRef.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        queryRef = queryRef.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (minRating != null) {
        queryRef = queryRef.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      if (inStock == true) {
        queryRef = queryRef.where('isAvailable', isEqualTo: true);
        queryRef = queryRef.where('stockQuantity', isGreaterThan: 0);
      }

      // Apply sorting
      switch (sortBy) {
        case 'price_low':
          queryRef = queryRef.orderBy('price', descending: false);
          break;
        case 'price_high':
          queryRef = queryRef.orderBy('price', descending: true);
          break;
        case 'rating':
          queryRef = queryRef.orderBy('rating', descending: true);
          break;
        case 'newest':
          queryRef = queryRef.orderBy('createdAt', descending: true);
          break;
        default:
          // For relevance, we'll sort by featured first, then by rating
          queryRef = queryRef.orderBy('isFeatured', descending: true);
      }

      final querySnapshot = await queryRef.get();
      List<ProductModel> products = querySnapshot.docs
          .map((doc) => ProductModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // If we have a search query, filter by text relevance
      if (query.isNotEmpty) {
        products = _filterByTextRelevance(products, query);
      }

      return products;
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  List<ProductModel> _filterByTextRelevance(List<ProductModel> products, String query) {
    final searchTerms = query.toLowerCase().split(' ');

    return products.where((product) {
      final searchableText =
          '${product.name} ${product.description} ${product.brand} ${product.category}'.toLowerCase();

      return searchTerms.any((term) => searchableText.contains(term));
    }).toList();
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      // Get suggestions from cached search history
      final history = _cacheService.getSearchHistory();
      final suggestions = history.where((item) => item.toLowerCase().contains(query.toLowerCase())).take(5).toList();

      // Add product name suggestions
      final productSuggestions = await _getProductNameSuggestions(query);
      suggestions.addAll(productSuggestions);

      return suggestions.toSet().toList(); // Remove duplicates
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getProductNameSuggestions(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(5)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getPopularSearchTerms() async {
    try {
      // In a real app, you might track search analytics
      // For now, return some predefined popular terms
      return [
        'milk',
        'bread',
        'eggs',
        'chicken',
        'rice',
        'pasta',
        'cheese',
        'yogurt',
        'bananas',
        'apples',
      ];
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      return querySnapshot.docs.map((doc) => doc.data()['name'] as String).toList();
    } catch (e) {
      // Fallback categories
      return [
        'Fruits & Vegetables',
        'Dairy & Eggs',
        'Meat & Seafood',
        'Bakery',
        'Pantry',
        'Frozen Foods',
        'Beverages',
        'Snacks',
        'Health & Beauty',
        'Household',
      ];
    }
  }

  Future<Map<String, dynamic>> getSearchFilters() async {
    try {
      final categories = await getCategories();

      return {
        'categories': categories,
        'priceRanges': [
          {'label': 'Under \$10', 'min': 0.0, 'max': 10.0},
          {'label': '\$10 - \$25', 'min': 10.0, 'max': 25.0},
          {'label': '\$25 - \$50', 'min': 25.0, 'max': 50.0},
          {'label': '\$50 - \$100', 'min': 50.0, 'max': 100.0},
          {'label': 'Over \$100', 'min': 100.0, 'max': null},
        ],
        'ratings': [
          {'label': '4+ Stars', 'value': 4.0},
          {'label': '3+ Stars', 'value': 3.0},
          {'label': '2+ Stars', 'value': 2.0},
          {'label': '1+ Star', 'value': 1.0},
        ],
        'sortOptions': [
          {'label': 'Relevance', 'value': 'relevance'},
          {'label': 'Price: Low to High', 'value': 'price_low'},
          {'label': 'Price: High to Low', 'value': 'price_high'},
          {'label': 'Customer Rating', 'value': 'rating'},
          {'label': 'Newest', 'value': 'newest'},
        ],
      };
    } catch (e) {
      return {};
    }
  }

  List<String> getSearchHistory() {
    return _cacheService.getSearchHistory();
  }

  Future<void> clearSearchHistory() async {
    await _cacheService.clearSearchHistory();
  }
}

import '/exports.dart';

class CacheService extends GetxService {
  final GetStorage _storage = GetStorage();
  final Duration _defaultCacheDuration = const Duration(hours: 24);

  static CacheService get to => Get.find();

  // Product caching
  Future<void> cacheProducts(List<ProductModel> products) async {
    final data = {
      'products': products.map((p) => p.toMap()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _storage.write('cached_products', data);
  }

  List<ProductModel>? getCachedProducts() {
    final data = _storage.read('cached_products');
    if (data == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
    if (DateTime.now().difference(timestamp) > _defaultCacheDuration) {
      _storage.remove('cached_products');
      return null;
    }

    return (data['products'] as List).map((p) => ProductModel.fromMap(Map<String, dynamic>.from(p))).toList();
  }

  // User preferences
  Future<void> cacheUserPreferences(Map<String, dynamic> preferences) async {
    await _storage.write('user_preferences', preferences);
  }

  Map<String, dynamic> getCachedUserPreferences() {
    return _storage.read('user_preferences') ?? {};
  }

  // Search history
  Future<void> addSearchQuery(String query) async {
    final history = getSearchHistory();
    history.remove(query); // Remove if exists to avoid duplicates
    history.insert(0, query); // Add to beginning

    // Keep only last 20 searches
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }

    await _storage.write('search_history', history);
  }

  List<String> getSearchHistory() {
    final history = _storage.read('search_history');
    return history != null ? List<String>.from(history) : [];
  }

  Future<void> clearSearchHistory() async {
    await _storage.remove('search_history');
  }

  // Cart backup
  Future<void> backupCart(List<CartItemModel> items) async {
    final data = {
      'items': items.map((item) => item.toMap()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _storage.write('cart_backup', data);
  }

  List<CartItemModel>? getCartBackup() {
    final data = _storage.read('cart_backup');
    if (data == null) return null;

    return (data['items'] as List).map((item) => CartItemModel.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  // Recently viewed products
  Future<void> addRecentlyViewed(String productId) async {
    final recent = getRecentlyViewed();
    recent.remove(productId); // Remove if exists
    recent.insert(0, productId); // Add to beginning

    // Keep only last 10 products
    if (recent.length > 10) {
      recent.removeRange(10, recent.length);
    }

    await _storage.write('recently_viewed', recent);
  }

  List<String> getRecentlyViewed() {
    final recent = _storage.read('recently_viewed');
    return recent != null ? List<String>.from(recent) : [];
  }

  // App settings
  Future<void> saveSetting(String key, dynamic value) async {
    await _storage.write('setting_$key', value);
  }

  T? getSetting<T>(String key, [T? defaultValue]) {
    return _storage.read('setting_$key') ?? defaultValue;
  }

  // Theme preference
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.write('theme_mode', mode.index);
  }

  ThemeMode getThemeMode() {
    final index = _storage.read('theme_mode');
    if (index == null) return ThemeMode.system;
    return ThemeMode.values[index];
  }

  // Language preference
  Future<void> saveLanguage(String languageCode) async {
    await _storage.write('language', languageCode);
  }

  String getLanguage() {
    return _storage.read('language') ?? 'en';
  }

  // Offline data management
  Future<void> cacheOfflineData(String key, Map<String, dynamic> data) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _storage.write('offline_$key', cacheData);
  }

  Map<String, dynamic>? getOfflineData(String key, {Duration? maxAge}) {
    final cacheData = _storage.read('offline_$key');
    if (cacheData == null) return null;

    final timestamp = DateTime.fromMillisecondsSinceEpoch(cacheData['timestamp']);
    final age = maxAge ?? _defaultCacheDuration;

    if (DateTime.now().difference(timestamp) > age) {
      _storage.remove('offline_$key');
      return null;
    }

    return Map<String, dynamic>.from(cacheData['data']);
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    final keys = _storage.getKeys();
    for (final key in keys) {
      if (key.startsWith('cached_') || key.startsWith('offline_')) {
        await _storage.remove(key);
      }
    }
  }

  // Check cache size and cleanup if needed
  Future<void> performMaintenance() async {
    final keys = _storage.getKeys();
    final now = DateTime.now();

    for (final key in keys) {
      if (key.startsWith('cached_') || key.startsWith('offline_')) {
        final data = _storage.read(key);
        if (data != null && data['timestamp'] != null) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
          if (now.difference(timestamp) > _defaultCacheDuration) {
            await _storage.remove(key);
          }
        }
      }
    }
  }
}

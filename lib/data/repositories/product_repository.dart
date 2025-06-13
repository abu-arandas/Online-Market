import '/exports.dart';

class ProductRepository {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Get all products
  Future<List<ProductModel>> getAllProducts({int limit = 20}) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'products',
        queryBuilder: (query) => query.limit(limit),
      );

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get products: $e';
    }
  }

  // Get featured products
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'products',
        queryBuilder: (query) => query.where('isFeatured', isEqualTo: true).limit(limit),
      );

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get featured products: $e';
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category, {int limit = 20}) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'products',
        queryBuilder: (query) => query.where('category', isEqualTo: category).limit(limit),
      );

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get products by category: $e';
    }
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String searchTerm, {int limit = 20}) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // In a real app, you would use a search service like Algolia or Elasticsearch
      // For now, we'll do a simple name-based search

      final querySnapshot = await _firebaseService.getDocuments(
        'products',
        queryBuilder: (query) => query
            .where('name', isGreaterThanOrEqualTo: searchTerm)
            .where('name', isLessThanOrEqualTo: '$searchTerm\uf8ff')
            .limit(limit),
      );

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to search products: $e';
    }
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firebaseService.getDocument('products', productId);

      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw 'Failed to get product: $e';
    }
  }

  // Alias for backwards compatibility
  Future<ProductModel?> getProduct(String productId) async {
    return getProductById(productId);
  }

  // Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'products',
        queryBuilder: (query) => query.where('barcode', isEqualTo: barcode).limit(1),
      );

      if (querySnapshot.docs.isNotEmpty) {
        return ProductModel.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw 'Failed to get product by barcode: $e';
    }
  }

  // Get products with discount
  Future<List<ProductModel>> getDiscountedProducts({int limit = 20}) async {
    try {
      final querySnapshot = await _firebaseService.getDocuments(
        'products',
        queryBuilder: (query) => query.where('discountPrice', isGreaterThan: 0).limit(limit),
      );

      return querySnapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw 'Failed to get discounted products: $e';
    }
  }

  // Create product (admin functionality)
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      await _firebaseService.createDocument('products', product.id, product.toMap());
      return product;
    } catch (e) {
      throw 'Failed to create product: $e';
    }
  }

  // Update product (admin functionality)
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final updatedProduct = product.copyWith(updatedAt: DateTime.now());
      await _firebaseService.updateDocument('products', product.id, updatedProduct.toMap());
      return updatedProduct;
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  // Delete product (admin functionality)
  Future<void> deleteProduct(String productId) async {
    try {
      await _firebaseService.deleteDocument('products', productId);
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  // Upload product image
  Future<String> uploadProductImage(Uint8List imageBytes, String productId) async {
    try {
      return await _firebaseService.uploadImage('products', imageBytes, fileName: productId);
    } catch (e) {
      throw 'Failed to upload product image: $e';
    }
  }

  // Listen to products stream
  Stream<List<ProductModel>> listenToProducts({int limit = 20}) {
    return _firebaseService
        .listenToDocuments(
      'products',
      queryBuilder: (query) => query.limit(limit),
    )
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Listen to featured products stream
  Stream<List<ProductModel>> listenToFeaturedProducts({int limit = 10}) {
    return _firebaseService
        .listenToDocuments(
      'products',
      queryBuilder: (query) => query.where('isFeatured', isEqualTo: true).limit(limit),
    )
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get product categories
  Future<List<String>> getProductCategories() async {
    try {
      // In a real app, you might have a separate categories collection
      // For now, return the predefined categories
      return AppConstants.productCategories;
    } catch (e) {
      throw 'Failed to get categories: $e';
    }
  }

  // Check product availability
  Future<bool> isProductAvailable(String productId, int requestedQuantity) async {
    try {
      final product = await getProductById(productId);

      if (product == null) return false;

      return product.isAvailable && product.stockQuantity >= requestedQuantity;
    } catch (e) {
      return false;
    }
  }
}

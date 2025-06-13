import '/exports.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';
  Future<List<ReviewModel>> getProductReviews(String productId, {int? limit}) async {
    try {
      var query = _firestore
          .collection(_collection)
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) => ReviewModel.fromMap({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      throw Exception('Failed to get product reviews: $e');
    }
  }

  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => ReviewModel.fromMap({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      throw Exception('Failed to get user reviews: $e');
    }
  }

  Future<String> addReview(ReviewModel review) async {
    try {
      final docRef = await _firestore.collection(_collection).add(review.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  // Alias for backwards compatibility
  Future<String> createReview(ReviewModel review) async {
    return addReview(review);
  }

  Future<void> updateReview(ReviewModel review) async {
    try {
      await _firestore.collection(_collection).doc(review.id).update(review.toMap());
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  Future<ReviewModel?> getUserReviewForProduct(String userId, String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return ReviewModel.fromMap({...doc.data(), 'id': doc.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user review: $e');
    }
  }

  Future<void> markReviewHelpful(String reviewId) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).update({
        'helpfulCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to mark review as helpful: $e');
    }
  }

  Stream<List<ReviewModel>> watchProductReviews(String productId) {
    return _firestore
        .collection(_collection)
        .where('productId', isEqualTo: productId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReviewModel.fromMap({...doc.data(), 'id': doc.id})).toList());
  }

  Future<Map<String, dynamic>> getProductRatingStats(String productId) async {
    try {
      final reviews = await getProductReviews(productId);
      if (reviews.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final totalRating = reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
      final averageRating = totalRating / reviews.length;

      final ratingDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (final review in reviews) {
        final rating = review.rating.round();
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }

      return {
        'averageRating': double.parse(averageRating.toStringAsFixed(1)),
        'totalReviews': reviews.length,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      throw Exception('Failed to get rating stats: $e');
    }
  }
}

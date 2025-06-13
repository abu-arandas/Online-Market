import '/exports.dart';

class WriteReviewController extends GetxController {
  final ReviewRepository _reviewRepository = Get.find<ReviewRepository>();
  final AuthController _authController = Get.find<AuthController>();

  // Reactive variables
  final productId = ''.obs;
  final productName = ''.obs;
  final rating = 0.obs;
  final reviewText = ''.obs;
  final selectedPhotos = <String>[].obs;
  final isSubmitting = false.obs;

  // Controllers
  final TextEditingController reviewController = TextEditingController();

  // Computed properties
  bool get canSubmit =>
      rating.value > 0 && reviewText.value.length >= 10 && reviewText.value.length <= 500 && !isSubmitting.value;

  String get ratingText {
    switch (rating.value) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap to rate';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeReview();
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  void _initializeReview() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      productId.value = args['productId'] ?? '';
      productName.value = args['productName'] ?? '';
    }
  }

  // Rating methods
  void setRating(int newRating) {
    rating.value = newRating;
  }

  // Review text methods
  void onReviewChanged(String text) {
    reviewText.value = text;
  }

  // Photo methods
  Future<void> addPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        selectedPhotos.add(image.path);
      }
    } catch (e) {
      AppHelpers.showSnackBar('Failed to pick image', isError: true);
    }
  }

  void removePhoto(String imagePath) {
    selectedPhotos.remove(imagePath);
  } // Submit methods

  Future<void> submitReview() async {
    if (!canSubmit || !_authController.isLoggedIn.value) {
      AppHelpers.showSnackBar('Please check your review details', isError: true);
      return;
    }

    try {
      isSubmitting.value = true;
      final user = _authController.currentUser.value;
      if (user == null) {
        AppHelpers.showSnackBar('User not logged in', isError: true);
        return;
      }

      final review = ReviewModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId.value,
        userId: user.id,
        userName: user.name,
        userAvatar: user.profileImageUrl ?? '',
        rating: rating.value.toDouble(),
        comment: reviewText.value.trim(),
        imageUrls: selectedPhotos.toList(),
        isVerifiedPurchase: false, // Can be set based on purchase history
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _reviewRepository.createReview(review);

      AppHelpers.showSnackBar('Review submitted successfully!');
      Get.back(result: true);
    } catch (e) {
      AppHelpers.showSnackBar('Failed to submit review', isError: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  // Validation methods
  bool validateReview() {
    if (rating.value == 0) {
      AppHelpers.showSnackBar('Please rate the product', isError: true);
      return false;
    }

    if (reviewText.value.trim().length < 10) {
      AppHelpers.showSnackBar('Review must be at least 10 characters', isError: true);
      return false;
    }

    if (reviewText.value.trim().length > 500) {
      AppHelpers.showSnackBar('Review must be less than 500 characters', isError: true);
      return false;
    }

    return true;
  }
}

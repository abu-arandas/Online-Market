import '/exports.dart';

class WriteReviewView extends GetView<WriteReviewController> {
  const WriteReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Review'),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.canSubmit ? controller.submitReview : null,
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info
            _buildProductInfo(),
            const SizedBox(height: AppConstants.spacing24),

            // Rating Section
            _buildRatingSection(),
            const SizedBox(height: AppConstants.spacing24),

            // Review Text
            _buildReviewSection(),
            const SizedBox(height: AppConstants.spacing24),

            // Photos Section (Optional)
            _buildPhotosSection(),
            const SizedBox(height: AppConstants.spacing32),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return CustomCard(
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              color: Colors.grey[200],
            ),
            child: const Icon(Icons.image_not_supported),
          ),
          const SizedBox(width: AppConstants.spacing12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.productName.value,
                      style: AppConstants.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                const SizedBox(height: AppConstants.spacing4),
                Text(
                  'Share your experience with this product',
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this product',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Star Rating
          Center(
            child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => controller.setRating(index + 1),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          index < controller.rating.value ? Icons.star : Icons.star_border,
                          color: index < controller.rating.value ? Colors.amber : Colors.grey,
                          size: 40,
                        ),
                      ),
                    );
                  }),
                )),
          ),
          const SizedBox(height: AppConstants.spacing12),

          // Rating Text
          Center(
            child: Obx(() => Text(
                  controller.ratingText,
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write your review',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing12),
          CustomInput(
            controller: controller.reviewController,
            hint: 'Share your thoughts about this product...',
            maxLines: 6,
            onChanged: controller.onReviewChanged,
          ),
          const SizedBox(height: AppConstants.spacing8),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${controller.reviewText.value.length}/500',
                    style: AppConstants.bodySmall.copyWith(
                      color: controller.reviewText.value.length > 500
                          ? AppConstants.errorColor
                          : AppConstants.textSecondaryColor,
                    ),
                  ),
                  if (controller.reviewText.value.length < 10)
                    Text(
                      'Minimum 10 characters',
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.errorColor,
                      ),
                    ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Add Photos',
                style: AppConstants.headingSmall,
              ),
              const Spacer(),
              Text(
                'Optional',
                style: AppConstants.bodySmall.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),

          // Photo Grid
          Obx(() => Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: [
                  // Selected Photos
                  ...controller.selectedPhotos.map((photo) => _buildPhotoItem(photo, isSelected: true)),

                  // Add Photo Button
                  if (controller.selectedPhotos.length < 3) _buildAddPhotoButton(),
                ],
              )),

          if (controller.selectedPhotos.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Tap to remove photos',
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoItem(String imagePath, {required bool isSelected}) {
    return GestureDetector(
      onTap: isSelected ? () => controller.removePhoto(imagePath) : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium - 2),
              child: Image.file(
                File(imagePath),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppConstants.errorColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: controller.addPhoto,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: AppConstants.primaryColor,
            width: 2,
            style: BorderStyle.solid,
          ),
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
        ),
        child: const Icon(
          Icons.add_photo_alternate,
          color: AppConstants.primaryColor,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => CustomButton(
          text: 'Submit Review',
          onPressed: controller.canSubmit ? controller.submitReview : null,
          isLoading: controller.isSubmitting.value,
          width: double.infinity,
        ));
  }
}

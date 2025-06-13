import '/exports.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.product.value?.name ?? 'Product Details',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
        actions: [
          // Wishlist Button
          Obx(() {
            if (controller.product.value == null) return const SizedBox.shrink();

            return WishlistButton(product: controller.product.value!);
          }),

          // Share Button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareProduct,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.product.value == null) {
          return const Center(
            child: Text('Product not found'),
          );
        }

        return _buildProductContent();
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductContent() {
    final product = controller.product.value!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Images Gallery
          _buildImageGallery(product),

          // Product Information
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name & Brand
                _buildProductHeader(product),
                const SizedBox(height: AppConstants.spacing12),

                // Price & Stock
                _buildPriceSection(product),
                const SizedBox(height: AppConstants.spacing16),

                // Rating & Reviews
                _buildRatingSection(product),
                const SizedBox(height: AppConstants.spacing20),

                // Description
                _buildDescriptionSection(product),
                const SizedBox(height: AppConstants.spacing20),

                // Nutrition Information
                if (product.nutritionInfo.isNotEmpty) _buildNutritionSection(product),
                const SizedBox(height: AppConstants.spacing20),

                // Quantity Selector
                _buildQuantitySelector(),
                const SizedBox(height: AppConstants.spacing24),

                // Reviews Section
                _buildReviewsSection(),
                const SizedBox(height: AppConstants.spacing20),

                // Related Products
                _buildRelatedProducts(),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(ProductModel product) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: controller.pageController,
        onPageChanged: controller.updateCurrentImageIndex,
        itemCount: product.imageUrls.isNotEmpty ? product.imageUrls.length : 1,
        itemBuilder: (context, index) {
          final imageUrl = product.imageUrls.isNotEmpty ? product.imageUrls[index] : '';

          return Container(
            width: double.infinity,
            color: Colors.grey[200],
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.grey,
                      );
                    },
                  )
                : const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildProductHeader(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: AppConstants.headingMedium,
        ),
        const SizedBox(height: AppConstants.spacing4),
        Text(
          product.brand,
          style: AppConstants.bodyMedium.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(ProductModel product) {
    return Row(
      children: [
        Text(
          AppHelpers.formatCurrency(product.effectivePrice),
          style: AppConstants.headingSmall.copyWith(
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: AppConstants.spacing8),
          Text(
            AppHelpers.formatCurrency(product.price),
            style: AppConstants.bodyMedium.copyWith(
              decoration: TextDecoration.lineThrough,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(width: AppConstants.spacing8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacing8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppConstants.errorColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Text(
              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: AppConstants.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              product.isInStock ? 'In Stock' : 'Out of Stock',
              style: AppConstants.bodySmall.copyWith(
                color: product.isInStock ? AppConstants.successColor : AppConstants.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${product.stockQuantity} ${product.unit} available',
              style: AppConstants.bodySmall.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(ProductModel product) {
    return Row(
      children: [
        RatingWidget(
          rating: product.rating,
          size: 20,
        ),
        const SizedBox(width: AppConstants.spacing8),
        Text(
          product.rating.toStringAsFixed(1),
          style: AppConstants.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppConstants.spacing4),
        Text(
          '(${product.reviewCount} reviews)',
          style: AppConstants.bodyMedium.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: AppConstants.headingSmall,
        ),
        const SizedBox(height: AppConstants.spacing8),
        Obx(() => AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  controller.isDescriptionExpanded.value ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: Text(
                product.description,
                style: AppConstants.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                product.description,
                style: AppConstants.bodyMedium,
              ),
            )),
        if (product.description.length > 150)
          TextButton(
            onPressed: controller.toggleDescription,
            child: Obx(() => Text(
                  controller.isDescriptionExpanded.value ? 'Show Less' : 'Show More',
                )),
          ),
      ],
    );
  }

  Widget _buildNutritionSection(ProductModel product) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Information',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing12),
          ...product.nutritionInfo.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: AppConstants.bodyMedium,
                  ),
                  Text(
                    entry.value.toString(),
                    style: AppConstants.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing12),
          Row(
            children: [
              IconButton(
                onPressed: controller.decreaseQuantity,
                icon: const Icon(Icons.remove_circle_outline),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing16,
                      vertical: AppConstants.spacing8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      '${controller.quantity.value}',
                      style: AppConstants.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              const SizedBox(width: AppConstants.spacing12),
              IconButton(
                onPressed: controller.increaseQuantity,
                icon: const Icon(Icons.add_circle_outline),
                style: IconButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                ),
              ),
              const Spacer(),
              Text(
                'Unit: ${controller.product.value!.unit}',
                style: AppConstants.bodyMedium.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reviews',
              style: AppConstants.headingSmall,
            ),
            TextButton(
              onPressed: controller.goToAllReviews,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacing12),
        Obx(() {
          if (controller.isLoadingReviews.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.reviews.isEmpty) {
            return CustomCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: AppConstants.textSecondaryColor,
                  ),
                  const SizedBox(height: AppConstants.spacing8),
                  const Text(
                    'No reviews yet',
                    style: AppConstants.bodyMedium,
                  ),
                  const SizedBox(height: AppConstants.spacing12),
                  CustomButton(
                    text: 'Write First Review',
                    onPressed: controller.writeReview,
                    isOutlined: true,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              ...controller.reviews.take(3).map((review) => _buildReviewCard(review)),
              const SizedBox(height: AppConstants.spacing12),
              CustomButton(
                text: 'Write a Review',
                onPressed: controller.writeReview,
                isOutlined: true,
                width: double.infinity,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        RatingWidget(
                          rating: review.rating,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.spacing8),
                        Text(
                          AppHelpers.formatDateTime(review.createdAt),
                          style: AppConstants.bodySmall.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          Text(
            review.comment,
            style: AppConstants.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Products',
          style: AppConstants.headingSmall,
        ),
        const SizedBox(height: AppConstants.spacing12),
        Obx(() {
          if (controller.relatedProducts.isEmpty) {
            return const SizedBox.shrink();
          }

          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.relatedProducts.length,
              itemBuilder: (context, index) {
                final product = controller.relatedProducts[index];
                return _buildRelatedProductCard(product);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRelatedProductCard(ProductModel product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: AppConstants.spacing12),
      child: CustomCard(
        onTap: () => controller.goToProduct(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                color: Colors.grey[200],
              ),
              child: product.primaryImageUrl.isNotEmpty
                  ? Image.network(
                      product.primaryImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    )
                  : const Icon(Icons.image_not_supported),
            ),
            const SizedBox(height: AppConstants.spacing8),

            // Product Name
            Text(
              product.name,
              style: AppConstants.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppConstants.spacing4),

            // Price
            Text(
              AppHelpers.formatCurrency(product.effectivePrice),
              style: AppConstants.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.product.value == null) {
          return const SizedBox.shrink();
        }

        final product = controller.product.value!;

        return Row(
          children: [
            // Total Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  Obx(() => Text(
                        AppHelpers.formatCurrency(
                          product.effectivePrice * controller.quantity.value,
                        ),
                        style: AppConstants.headingSmall.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
            ),

            // Action Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add to Cart Button
                CustomButton(
                  text: 'Add to Cart',
                  onPressed: product.isInStock ? controller.addToCart : null,
                  isOutlined: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing20,
                    vertical: AppConstants.spacing12,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing12),

                // Buy Now Button
                CustomButton(
                  text: 'Buy Now',
                  onPressed: product.isInStock ? controller.buyNow : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing20,
                    vertical: AppConstants.spacing12,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

import '/exports.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: controller.scanBarcode,
          ),
          Obx(() {
            final cartController = Get.find<CartController>();
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: controller.goToCart,
                ),
                if (cartController.cartItemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppConstants.errorColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cartController.cartItemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          controller: controller.scrollController,
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildGreeting(),
              const SizedBox(height: AppConstants.spacing20),

              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: AppConstants.spacing20),

              // Featured Carousel
              _buildFeaturedCarousel(),
              const SizedBox(height: AppConstants.spacing24),

              // Categories
              _buildCategories(),
              const SizedBox(height: AppConstants.spacing24),

              // Featured Products
              _buildFeaturedProducts(),
              const SizedBox(height: AppConstants.spacing24),

              // All Products
              _buildAllProducts(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildGreeting() {
    return Obx(() => Text(
          controller.greetingMessage,
          style: AppConstants.headingMedium,
        ));
  }

  Widget _buildSearchBar() {
    return CustomInput(
      controller: controller.searchController,
      hint: 'Search for products...',
      prefixIcon: const Icon(Icons.search),
      onChanged: controller.searchProducts,
      suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: controller.clearSearch,
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildFeaturedCarousel() {
    return Obx(() => SizedBox(
          height: 200,
          child: CarouselSlider(
            items: controller.carouselImages.map((imagePath) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                controller.updateCarouselIndex(index);
              },
            ),
          ),
        ));
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: AppConstants.headingSmall,
        ),
        const SizedBox(height: AppConstants.spacing12),
        Obx(() => SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  final isSelected = controller.selectedCategory.value == category;

                  return Container(
                    margin: const EdgeInsets.only(right: AppConstants.spacing8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.filterByCategory(selected ? category : '');
                      },
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Products',
          style: AppConstants.headingSmall,
        ),
        const SizedBox(height: AppConstants.spacing12),
        Obx(() {
          if (controller.featuredProducts.isEmpty) {
            return const Center(child: Text('No featured products available'));
          }

          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.featuredProducts.length,
              itemBuilder: (context, index) {
                final product = controller.featuredProducts[index];
                return _buildProductCard(product, isHorizontal: true);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAllProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              controller.pageTitle,
              style: AppConstants.headingSmall,
            )),
        const SizedBox(height: AppConstants.spacing12),
        Obx(() {
          if (controller.isLoading.value && controller.displayedProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!controller.hasProducts) {
            return const Center(child: Text('No products found'));
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppConstants.spacing12,
              mainAxisSpacing: AppConstants.spacing12,
            ),
            itemCount: controller.displayedProducts.length,
            itemBuilder: (context, index) {
              final product = controller.displayedProducts[index];
              return _buildProductCard(product);
            },
          );
        }),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, {bool isHorizontal = false}) {
    return CustomCard(
      onTap: () => controller.goToProductDetails(product),
      child: SizedBox(
        width: isHorizontal ? 160 : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: isHorizontal ? 100 : 120,
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
            Row(
              children: [
                Text(
                  AppHelpers.formatCurrency(product.effectivePrice),
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                if (product.hasDiscount) ...[
                  const SizedBox(width: AppConstants.spacing8),
                  Text(
                    AppHelpers.formatCurrency(product.price),
                    style: AppConstants.bodySmall.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Add to Cart',
                onPressed: () => controller.addToCart(product),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            // Navigate to categories
            break;
          case 2:
            controller.goToCart();
            break;
          case 3:
            controller.goToProfile();
            break;
        }
      },
    );
  }
}

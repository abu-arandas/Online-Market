import '/exports.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return _buildSearchSuggestions();
              } else if (controller.isLoading.value) {
                return _buildLoadingView();
              } else if (controller.searchResults.isEmpty) {
                return _buildNoResultsView();
              } else {
                return _buildSearchResults();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              onChanged: (value) {
                if (!value.isNotEmpty) {
                  controller.clearSearch();
                }
              },
              onSubmitted: (value) => controller.search(value),
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          // Voice Search Button
          Obx(() => IconButton(
                icon: Icon(
                  controller.isListening.value ? Icons.mic : Icons.mic_none,
                  color: controller.isListening.value ? AppConstants.primaryColor : Colors.grey,
                ),
                onPressed: controller.toggleVoiceSearch,
                tooltip: 'Voice Search',
              )),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      if (!controller.hasActiveFilters) return const SizedBox.shrink();

      return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            if (controller.selectedCategory.value != null)
              _buildFilterChip(
                'Category: ${controller.selectedCategory.value}',
                () => controller.setCategory(null),
              ),
            if (controller.minPrice.value != null || controller.maxPrice.value != null)
              _buildFilterChip(
                'Price: \$${controller.minPrice.value ?? 0} - \$${controller.maxPrice.value ?? '∞'}',
                () => controller.setPriceRange(null, null),
              ),
            if (controller.minRating.value != null)
              _buildFilterChip(
                'Rating: ${controller.minRating.value}+ ⭐',
                () => controller.setMinRating(null),
              ),
            if (controller.inStockOnly.value)
              _buildFilterChip(
                'In Stock Only',
                () => controller.toggleInStockOnly(),
              ),
            if (controller.sortBy.value != 'relevance')
              _buildFilterChip(
                'Sort: ${_getSortDisplayName(controller.sortBy.value)}',
                () => controller.setSortBy('relevance'),
              ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: controller.clearFilters,
              child: const Text('Clear All'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onDeleted: onRemove,
        deleteIconColor: Colors.grey[600],
        backgroundColor: Colors.blue[50],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (controller.suggestions.isNotEmpty) {
              return _buildSuggestionsSection();
            }
            return const SizedBox.shrink();
          }),
          _buildSearchHistorySection(),
          _buildPopularSearchesSection(),
          _buildCategoriesSection(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggestions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...controller.suggestions.map((suggestion) => ListTile(
              leading: const Icon(Icons.search, color: Colors.grey),
              title: Text(suggestion),
              onTap: () => controller.selectSuggestion(suggestion),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSearchHistorySection() {
    return Obx(() {
      if (controller.searchHistory.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controller.searchHistory.take(5).map((query) => ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.call_made, size: 16),
                  onPressed: () => controller.searchFromHistory(query),
                ),
                onTap: () => controller.searchFromHistory(query),
              )),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildPopularSearchesSection() {
    return Obx(() {
      if (controller.popularSearches.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Searches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.popularSearches
                .map(
                  (search) => ActionChip(
                    label: Text(search),
                    onPressed: () => controller.search(search),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildCategoriesSection() {
    return Obx(() {
      if (controller.categories.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              return GestureDetector(
                onTap: () {
                  controller.setCategory(category);
                  controller.search('');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching products...'),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found for "${controller.searchQuery.value}"',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text('Try adjusting your search or filters'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.clearFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        final product = controller.searchResults[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => controller.navigateToProduct(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: product.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrls.first,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        Text(
                          ' ${product.rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        if (!product.isAvailable || product.stockQuantity == 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryFilter(),
                    const SizedBox(height: 24),
                    _buildPriceFilter(),
                    const SizedBox(height: 24),
                    _buildRatingFilter(),
                    const SizedBox(height: 24),
                    _buildStockFilter(),
                    const SizedBox(height: 24),
                    _buildSortFilter(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.search(controller.searchQuery.value);
                  Get.back();
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.categories.map((category) {
                final isSelected = controller.selectedCategory.value == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.setCategory(selected ? category : null);
                  },
                );
              }).toList(),
            ),
          ],
        ));
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() {
          final filterOptions = controller.filterOptions['priceRanges'] as List?;
          if (filterOptions == null) return const SizedBox.shrink();

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filterOptions.map<Widget>((range) {
              final min = range['min'] as double?;
              final max = range['max'] as double?;
              final isSelected = controller.minPrice.value == min && controller.maxPrice.value == max;

              return FilterChip(
                label: Text(range['label']),
                selected: isSelected,
                onSelected: (selected) {
                  controller.setPriceRange(
                    selected ? min : null,
                    selected ? max : null,
                  );
                },
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Minimum Rating', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() {
          final filterOptions = controller.filterOptions['ratings'] as List?;
          if (filterOptions == null) return const SizedBox.shrink();

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filterOptions.map<Widget>((rating) {
              final value = rating['value'] as double;
              final isSelected = controller.minRating.value == value;

              return FilterChip(
                label: Text(rating['label']),
                selected: isSelected,
                onSelected: (selected) {
                  controller.setMinRating(selected ? value : null);
                },
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildStockFilter() {
    return Obx(() => CheckboxListTile(
          title: const Text('In Stock Only'),
          value: controller.inStockOnly.value,
          onChanged: (value) => controller.toggleInStockOnly(),
          contentPadding: EdgeInsets.zero,
        ));
  }

  Widget _buildSortFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Obx(() {
          final filterOptions = controller.filterOptions['sortOptions'] as List?;
          if (filterOptions == null) return const SizedBox.shrink();

          return Column(
            children: filterOptions.map<Widget>((sort) {
              final value = sort['value'] as String;

              return RadioListTile<String>(
                title: Text(sort['label']),
                value: value,
                groupValue: controller.sortBy.value,
                onChanged: (newValue) {
                  if (newValue != null) {
                    controller.setSortBy(newValue);
                  }
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  String _getSortDisplayName(String sortValue) {
    switch (sortValue) {
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'rating':
        return 'Customer Rating';
      case 'newest':
        return 'Newest';
      default:
        return 'Relevance';
    }
  }
}

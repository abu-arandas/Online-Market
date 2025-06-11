import '/exports.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Obx(() => controller.isNotEmpty
              ? TextButton(
                  onPressed: _showClearCartDialog,
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.isEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildCartItem(item);
                },
              ),
            ),
            _buildCartSummary(),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppConstants.emptyCartPath,
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.shopping_cart_outlined,
                  size: 100,
                  color: AppConstants.textSecondaryColor,
                );
              },
            ),
            const SizedBox(height: AppConstants.spacing24),
            const Text(
              'Your cart is empty',
              style: AppConstants.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Add items to your cart to see them here',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing24),
            CustomButton(
              text: 'Start Shopping',
              onPressed: () => Get.back(),
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing12),
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
            child: item.productImage.isNotEmpty
                ? Image.network(
                    item.productImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  )
                : const Icon(Icons.image_not_supported),
          ),
          const SizedBox(width: AppConstants.spacing12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppConstants.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacing4),
                Row(
                  children: [
                    Text(
                      controller.formatPrice(item.effectivePrice),
                      style: AppConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    if (item.hasDiscount) ...[
                      const SizedBox(width: AppConstants.spacing8),
                      Text(
                        controller.formatPrice(item.price),
                        style: AppConstants.bodySmall.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppConstants.spacing8),
                Text(
                  'Unit: ${item.unit}',
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Controls
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => controller.updateItemQuantity(
                      item.productId,
                      item.quantity - 1,
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                  ),
                  Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: AppConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.updateItemQuantity(
                      item.productId,
                      item.quantity + 1,
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 20,
                  ),
                ],
              ),
              TextButton(
                onPressed: () => controller.removeItemFromCart(item.productId),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: AppConstants.errorColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
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
      child: Column(
        children: [
          // Discount Code Section
          if (!controller.hasDiscount()) ...[
            Row(
              children: [
                Expanded(
                  child: CustomInput(
                    controller: controller.discountController,
                    hint: 'Enter discount code',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing12,
                      vertical: AppConstants.spacing8,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacing8),
                CustomButton(
                  text: 'Apply',
                  onPressed: controller.applyDiscountCode,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing16,
                    vertical: AppConstants.spacing8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],

          // Applied Discount
          if (controller.hasDiscount()) ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer,
                    color: AppConstants.successColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppConstants.spacing8),
                  Expanded(
                    child: Text(
                      'Discount applied: ${controller.discountCode.value}',
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.removeDiscount,
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: AppConstants.errorColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacing16),
          ],

          // Price Breakdown
          Column(
            children: [
              _buildSummaryRow('Subtotal', controller.formatPrice(controller.cartSubtotal)),
              Obx(() => _buildSummaryRow('Delivery', controller.deliveryFeeText)),
              if (controller.hasDiscount())
                Obx(() => _buildSummaryRow(
                      'Discount',
                      '-${controller.formatPrice(controller.discount.value)}',
                      color: AppConstants.successColor,
                    )),
              const Divider(),
              Obx(() => _buildSummaryRow(
                    'Total',
                    controller.formatPrice(controller.cartTotal),
                    isTotal: true,
                  )),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Checkout Button
          Obx(() => CustomButton(
                text: 'Proceed to Checkout',
                onPressed: controller.goToCheckout,
                isLoading: controller.isCheckingOut.value,
                width: double.infinity,
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    final textStyle = isTotal ? AppConstants.bodyLarge.copyWith(fontWeight: FontWeight.bold) : AppConstants.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textStyle.copyWith(color: color),
          ),
          Text(
            value,
            style: textStyle.copyWith(
              color: color ?? (isTotal ? AppConstants.primaryColor : null),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

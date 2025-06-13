import '/exports.dart';

class CheckoutView extends GetView<CartController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address Section
            _buildDeliveryAddressSection(),
            const SizedBox(height: AppConstants.spacing20),

            // Payment Method Section
            _buildPaymentMethodSection(),
            const SizedBox(height: AppConstants.spacing20),

            // Order Notes Section
            _buildOrderNotesSection(),
            const SizedBox(height: AppConstants.spacing20),

            // Order Summary Section
            _buildOrderSummarySection(),
            const SizedBox(height: AppConstants.spacing24),

            // Place Order Button
            _buildPlaceOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Address',
                style: AppConstants.headingSmall,
              ),
              TextButton(
                onPressed: controller.goToAddresses,
                child: const Text('Change'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing12),
          Obx(() {
            final address = controller.selectedAddress.value;
            if (address == null) {
              return Column(
                children: [
                  const Text('No address selected'),
                  const SizedBox(height: AppConstants.spacing8),
                  CustomButton(
                    text: 'Add Address',
                    onPressed: controller.goToAddAddress,
                    isOutlined: true,
                  ),
                ],
              );
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacing12),
              decoration: BoxDecoration(
                border: Border.all(color: AppConstants.primaryColor),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    style: AppConstants.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    address.fullAddress,
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
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

  Widget _buildPaymentMethodSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing12),
          Obx(() => Column(
                children: controller.paymentMethods.map((method) {
                  return RadioListTile<String>(
                    value: method['id'],
                    groupValue: controller.paymentMethod.value,
                    onChanged: (value) => controller.selectPaymentMethod(value!),
                    title: Row(
                      children: [
                        Icon(
                          method['icon'],
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: AppConstants.spacing8),
                        Text(method['name']),
                      ],
                    ),
                    activeColor: AppConstants.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderNotesSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Notes (Optional)',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing12),
          CustomInput(
            controller: controller.notesController,
            hint: 'Any special instructions for delivery...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing12),

          // Order Items
          Obx(() => Column(
                children: controller.cartItems
                    .map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.productName}',
                                  style: AppConstants.bodyMedium,
                                ),
                              ),
                              Text(
                                controller.formatPrice(item.totalPrice),
                                style: AppConstants.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              )),

          const Divider(height: AppConstants.spacing20),

          // Price Breakdown
          Obx(() => Column(
                children: [
                  _buildSummaryRow('Subtotal', controller.formatPrice(controller.cartSubtotal)),
                  _buildSummaryRow('Delivery', controller.deliveryFeeText),
                  if (controller.hasDiscount())
                    _buildSummaryRow(
                      'Discount',
                      '-${controller.formatPrice(controller.discount.value)}',
                      color: AppConstants.successColor,
                    ),
                  const Divider(),
                  _buildSummaryRow(
                    'Total',
                    controller.formatPrice(controller.cartTotal),
                    isTotal: true,
                  ),
                ],
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

  Widget _buildPlaceOrderButton() {
    return Obx(() => CustomButton(
          text: 'Place Order • ${controller.formatPrice(controller.cartTotal)}',
          onPressed: controller.checkout,
          isLoading: controller.isCheckingOut.value,
          width: double.infinity,
        ));
  }
}

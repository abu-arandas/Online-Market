import '/exports.dart';
import '../controllers/map_controller.dart' as local;

class MapView extends GetView<local.MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: controller.getCurrentLocation,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppConstants.spacing16),
                Text('Getting your location...'),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Map placeholder (since flutter_map requires additional setup)
            Expanded(
              flex: 2,
              child: _buildMapPlaceholder(),
            ),

            // Location details
            Expanded(
              flex: 1,
              child: _buildLocationDetails(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            'Map View',
            style: AppConstants.headingMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Obx(() => controller.currentPosition.value != null
              ? Text(
                  'Lat: ${controller.currentPosition.value!.latitude.toStringAsFixed(4)}\n'
                  'Lng: ${controller.currentPosition.value!.longitude.toStringAsFixed(4)}',
                  textAlign: TextAlign.center,
                  style: AppConstants.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                )
              : Text(
                  'Location not available',
                  style: AppConstants.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusLarge),
          topRight: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Address
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: AppConstants.spacing8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: AppConstants.bodySmall.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    Obx(() => Text(
                          controller.currentAddress.value.isNotEmpty
                              ? controller.currentAddress.value
                              : 'Getting address...',
                          style: AppConstants.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Delivery Information
          CustomCard(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Column(
              children: [
                _buildInfoRow(
                  'Delivery Status',
                  Obx(() => Text(
                        controller.deliveryAreaStatus,
                        style: AppConstants.bodyMedium.copyWith(
                          color: controller.deliveryAreaStatusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildInfoRow(
                  'Delivery Fee',
                  Obx(() => Text(
                        controller.formattedDeliveryFee,
                        style: AppConstants.bodyMedium.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ),
                const SizedBox(height: AppConstants.spacing12),
                _buildInfoRow(
                  'Estimated Time',
                  Obx(() => Text(
                        controller.estimatedDeliveryTime.value.isNotEmpty
                            ? controller.estimatedDeliveryTime.value
                            : 'Calculating...',
                        style: AppConstants.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Refresh Location',
                  onPressed: controller.getCurrentLocation,
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: AppConstants.spacing12),
              Expanded(
                child: CustomButton(
                  text: 'Use This Location',
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppConstants.bodyMedium,
        ),
        value,
      ],
    );
  }
}

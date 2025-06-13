import '/exports.dart';

class MapController extends GetxController {
  final MappingService _mappingService = Get.find<MappingService>();

  // Observables
  final RxBool isLoading = false.obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxString currentAddress = ''.obs;
  final RxDouble deliveryFee = 0.0.obs;
  final RxString estimatedDeliveryTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      final hasPermission = await _mappingService.hasLocationPermission();
      if (!hasPermission) {
        final granted = await _mappingService.requestLocationPermission();
        if (!granted) {
          AppHelpers.showSnackBar('Location permission is required', isError: true);
          return;
        }
      }

      final position = await _mappingService.getCurrentLocation();
      if (position != null) {
        currentPosition.value = position;
        await _updateLocationDetails(position);
      }
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Update location details
  Future<void> _updateLocationDetails(Position position) async {
    try {
      // Get address from coordinates
      final address = await _mappingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      currentAddress.value = address;

      // Calculate delivery fee
      final fee = _mappingService.calculateDeliveryFee(
        _mappingService.calculateDistance(
          31.9539, // Store location (example)
          35.9106,
          position.latitude,
          position.longitude,
        ),
      );
      deliveryFee.value = fee;

      // Get delivery time estimate
      final timeEstimate = _mappingService.getDeliveryTimeEstimate(
        _mappingService.calculateDistance(
          31.9539,
          35.9106,
          position.latitude,
          position.longitude,
        ),
      );
      estimatedDeliveryTime.value = '${timeEstimate.inMinutes} minutes';
    } catch (e) {
      AppHelpers.showSnackBar('Failed to get location details', isError: true);
    }
  }

  // Check if location is within delivery area
  bool isWithinDeliveryArea() {
    if (currentPosition.value == null) return false;

    return _mappingService.isWithinDeliveryArea(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
    );
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await _mappingService.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await _mappingService.openAppSettings();
  }

  // Format delivery fee
  String get formattedDeliveryFee {
    return deliveryFee.value == 0 ? 'Free' : AppHelpers.formatCurrency(deliveryFee.value);
  }

  // Get delivery area status
  String get deliveryAreaStatus {
    if (currentPosition.value == null) return 'Location unknown';
    return isWithinDeliveryArea() ? 'Available' : 'Not available';
  }

  // Get delivery area status color
  Color get deliveryAreaStatusColor {
    if (currentPosition.value == null) return AppConstants.textSecondaryColor;
    return isWithinDeliveryArea() ? AppConstants.successColor : AppConstants.errorColor;
  }
}

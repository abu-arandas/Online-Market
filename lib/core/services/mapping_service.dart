import '/exports.dart';

class MappingService extends GetxService {
  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      } // Get current position
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      throw 'Failed to get current location: $e';
    }
  }

  // Get address from coordinates (Reverse Geocoding)
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // This is a placeholder implementation
      // In a real app, you would use a geocoding service like Google Maps API
      return 'Address for coordinates: $latitude, $longitude';
    } catch (e) {
      throw 'Failed to get address: $e';
    }
  }

  // Get coordinates from address (Geocoding)
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      // This is a placeholder implementation
      // In a real app, you would use a geocoding service like Google Maps API
      // For now, return a default position
      return Position(
        latitude: 31.9539,
        longitude: 35.9106,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        floor: null,
        isMocked: false,
      );
    } catch (e) {
      throw 'Failed to get coordinates: $e';
    }
  }

  // Calculate distance between two points
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Calculate delivery fee based on distance
  double calculateDeliveryFee(double distanceInMeters) {
    const double baseFee = 2.0;
    const double feePerKm = 1.0;

    // Free delivery for distances less than 2km
    if (distanceInMeters < 2000) {
      return 0.0;
    }

    double distanceInKm = distanceInMeters / 1000;
    return baseFee + (distanceInKm * feePerKm);
  }

  // Check if location is within delivery area
  bool isWithinDeliveryArea(double latitude, double longitude) {
    // Define your delivery area bounds
    const double centerLatitude = 31.9539; // Amman, Jordan
    const double centerLongitude = 35.9106;
    const double maxDeliveryRadius = 20000; // 20km in meters

    double distance = calculateDistance(
      centerLatitude,
      centerLongitude,
      latitude,
      longitude,
    );

    return distance <= maxDeliveryRadius;
  }

  // Get delivery time estimate based on distance
  Duration getDeliveryTimeEstimate(double distanceInMeters) {
    // Base delivery time is 30 minutes
    int baseMinutes = 30;

    // Add 5 minutes for every 5km
    int additionalMinutes = ((distanceInMeters / 5000).ceil()) * 5;

    return Duration(minutes: baseMinutes + additionalMinutes);
  }

  // Format distance for display
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  // Check location permissions
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  // Request location permissions
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

}

import '/exports.dart';

class AddressController extends GetxController {
  static AddressController instance = Get.find();

  @override
  void onInit() {
    super.onInit();

    permission();
  }

  permission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    }

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then(
      (position) {
        currentAddress = LatLng(position.latitude, position.longitude);

        update();
      },
    );
  }

  LatLng currentAddress = const LatLng(31.9859666, 35.9265862);

  List<LatLng> addresses = [];

  Future<String> addressName(LatLng address) async {
    return 'placemarks.first';
  }
}

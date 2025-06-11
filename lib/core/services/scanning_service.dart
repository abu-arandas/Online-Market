import '/exports.dart';

class ScanningService extends GetxService {
  // Scan barcode using camera
  Future<String?> scanBarcode() async {
    try {
      // Note: This requires adding barcode_scan2 package
      // For now, this is a placeholder implementation
      // In a real implementation, you would use a barcode scanning library

      // Simulate barcode scanning
      await Future.delayed(const Duration(seconds: 2));

      // Return a mock barcode
      return '1234567890123';
    } catch (e) {
      throw 'Failed to scan barcode: $e';
    }
  }

  // Generate barcode widget
  Widget generateBarcodeWidget(
    String data, {
    Barcode? type,
    double width = 200,
    double height = 80,
  }) {
    try {
      return BarcodeWidget(
        barcode: type ?? Barcode.code128(),
        data: data,
        width: width,
        height: height,
        drawText: true,
        style: const TextStyle(fontSize: 12),
      );
    } catch (e) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Center(
          child: Text(
            'Invalid Barcode',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  // Validate barcode format
  bool isValidBarcode(String barcode, [String? type]) {
    try {
      if (type == null) return barcode.isNotEmpty;

      switch (type.toLowerCase()) {
        case 'code128':
          return barcode.isNotEmpty && barcode.length <= 48;
        case 'ean13':
          return barcode.length == 13 && RegExp(r'^[0-9]+$').hasMatch(barcode);
        case 'ean8':
          return barcode.length == 8 && RegExp(r'^[0-9]+$').hasMatch(barcode);
        case 'upca':
          return barcode.length == 12 && RegExp(r'^[0-9]+$').hasMatch(barcode);
        case 'upce':
          return barcode.length == 8 && RegExp(r'^[0-9]+$').hasMatch(barcode);
        default:
          return barcode.isNotEmpty;
      }
    } catch (e) {
      return false;
    }
  }

  // Get barcode type from string
  Barcode getBarcodeType(String barcode) {
    if (barcode.length == 13 && RegExp(r'^[0-9]+$').hasMatch(barcode)) {
      return Barcode.ean13();
    } else if (barcode.length == 8 && RegExp(r'^[0-9]+$').hasMatch(barcode)) {
      return Barcode.ean8();
    } else if (barcode.length == 12 && RegExp(r'^[0-9]+$').hasMatch(barcode)) {
      return Barcode.upcA();
    } else {
      return Barcode.code128();
    }
  }

  // Search product by barcode
  Future<ProductModel?> searchProductByBarcode(String barcode) async {
    try {
      final firebaseService = Get.find<FirebaseService>();

      final querySnapshot = await firebaseService.getDocuments(
        'products',
        queryBuilder: (query) => query.where('barcode', isEqualTo: barcode).limit(1),
      );

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw 'Failed to search product: $e';
    }
  }

  // Generate product barcode
  String generateProductBarcode() {
    // Generate a simple EAN-13 barcode
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    String barcode = random.substring(random.length - 12);

    // Calculate check digit for EAN-13
    int checkDigit = calculateEAN13CheckDigit(barcode);
    return barcode + checkDigit.toString();
  }

  // Calculate EAN-13 check digit
  int calculateEAN13CheckDigit(String barcode) {
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(barcode[i]);
      if (i % 2 == 0) {
        sum += digit;
      } else {
        sum += digit * 3;
      }
    }
    int remainder = sum % 10;
    return remainder == 0 ? 0 : 10 - remainder;
  }

  // Save barcode image
  Future<Uint8List> generateBarcodeImage(
    String data, {
    Barcode? type,
    double width = 200,
    double height = 80,
  }) async {
    try {
      // This would require additional image generation libraries
      // For now, return empty bytes
      return Uint8List(0);
    } catch (e) {
      throw 'Failed to generate barcode image: $e';
    }
  }

  // Check camera permission
  Future<bool> hasCameraPermission() async {
    // This would require permission_handler package
    // For now, assume permission is granted
    return true;
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    // This would require permission_handler package
    // For now, assume permission is granted
    return true;
  }

}

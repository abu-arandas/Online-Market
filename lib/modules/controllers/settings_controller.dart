import '/exports.dart';

class SettingsController extends GetxController {
  final BiometricService _biometricService = Get.find<BiometricService>();
  final NotificationService _notificationService = Get.find<NotificationService>();

  // Observable variables
  final notificationsEnabled = true.obs;
  final pushNotificationsEnabled = true.obs;
  final emailNotificationsEnabled = true.obs;
  final smsNotificationsEnabled = false.obs;
  final biometricEnabled = false.obs;
  final locationEnabled = true.obs;
  final autoBackupEnabled = true.obs;
  final dataSync = true.obs;
  final language = 'en'.obs;
  final currency = 'USD'.obs;

  // App info
  final appVersion = ''.obs;
  final buildNumber = ''.obs;

  // Available options
  final availableLanguages = <Map<String, String>>[
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'ja', 'name': '日本語'},
  ].obs;

  final availableCurrencies = <Map<String, String>>[
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'CHF'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
    {'code': 'JOD', 'name': 'Jordanian Dinar', 'symbol': 'JD'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
      buildNumber.value = packageInfo.buildNumber;
    } catch (e) {
      print('Error loading app info: $e');
    }
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;

    if (!value) {
      // Disable all notification types if main toggle is off
      await togglePushNotifications(false);
      await toggleEmailNotifications(false);
      await toggleSmsNotifications(false);
    }

    _showSettingUpdatedSnackbar('Notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> togglePushNotifications(bool value) async {
    if (!notificationsEnabled.value && value) {
      _showErrorSnackbar('Please enable notifications first');
      return;
    }

    pushNotificationsEnabled.value = value;

    if (value) {
      await _notificationService.subscribeToTopic('all_users');
    } else {
      await _notificationService.unsubscribeFromTopic('all_users');
    }

    _showSettingUpdatedSnackbar('Push notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleEmailNotifications(bool value) async {
    if (!notificationsEnabled.value && value) {
      _showErrorSnackbar('Please enable notifications first');
      return;
    }

    emailNotificationsEnabled.value = value;
    _showSettingUpdatedSnackbar('Email notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleSmsNotifications(bool value) async {
    if (!notificationsEnabled.value && value) {
      _showErrorSnackbar('Please enable notifications first');
      return;
    }

    smsNotificationsEnabled.value = value;
    _showSettingUpdatedSnackbar('SMS notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleBiometric(bool value) async {
    if (value) {
      final success = await _biometricService.setupBiometricLogin();
      biometricEnabled.value = success;
    } else {
      await _biometricService.disableBiometricLogin();
      biometricEnabled.value = false;
    }
  }

  Future<void> toggleLocation(bool value) async {
    locationEnabled.value = value;
    _showSettingUpdatedSnackbar('Location services ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleAutoBackup(bool value) async {
    autoBackupEnabled.value = value;
    _showSettingUpdatedSnackbar('Auto backup ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleDataSync(bool value) async {
    dataSync.value = value;
    _showSettingUpdatedSnackbar('Data sync ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> setLanguage(String languageCode) async {
    language.value = languageCode;

    final languageName = availableLanguages.firstWhere((lang) => lang['code'] == languageCode)['name'];

    _showSettingUpdatedSnackbar('Language changed to $languageName');

    // Update app locale
    final locale = Locale(languageCode);
    Get.updateLocale(locale);
  }

  Future<void> setCurrency(String currencyCode) async {
    currency.value = currencyCode;

    final currencyName = availableCurrencies.firstWhere((curr) => curr['code'] == currencyCode)['name'];

    _showSettingUpdatedSnackbar('Currency changed to $currencyName');
  }

  Future<void> deleteAccount() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Implementation for account deletion
        final AuthController authController = Get.find<AuthController>();
        await authController.deleteAccount();
      } catch (e) {
        _showErrorSnackbar('Failed to delete account: $e');
      }
    }
  }

  void showLanguageSelector() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...availableLanguages.map((lang) {
              final isSelected = lang['code'] == language.value;
              return ListTile(
                title: Text(lang['name']!),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  setLanguage(lang['code']!);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void showCurrencySelector() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Currency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...availableCurrencies.map((curr) {
              final isSelected = curr['code'] == currency.value;
              return ListTile(
                title: Text('${curr['name']} (${curr['symbol']})'),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  setCurrency(curr['code']!);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSettingUpdatedSnackbar(String message) {
    Get.snackbar(
      'Setting Updated',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  String get currentLanguageName {
    return availableLanguages.firstWhere((lang) => lang['code'] == language.value)['name']!;
  }

  String get currentCurrencyName {
    return availableCurrencies.firstWhere((curr) => curr['code'] == currency.value)['name']!;
  }

  String get currentCurrencySymbol {
    return availableCurrencies.firstWhere((curr) => curr['code'] == currency.value)['symbol']!;
  }
}

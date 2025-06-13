import '/exports.dart';

class SettingsController extends GetxController {
  final CacheService _cacheService = Get.find<CacheService>();
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
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    // Load notification settings
    notificationsEnabled.value = _cacheService.getSetting<bool>('notifications_enabled', true) ?? true;
    pushNotificationsEnabled.value = _cacheService.getSetting<bool>('push_notifications_enabled', true) ?? true;
    emailNotificationsEnabled.value = _cacheService.getSetting<bool>('email_notifications_enabled', true) ?? true;
    smsNotificationsEnabled.value = _cacheService.getSetting<bool>('sms_notifications_enabled', false) ?? false;

    // Load biometric settings
    biometricEnabled.value = _biometricService.isBiometricEnabled() ?? false;

    // Load other settings
    locationEnabled.value = _cacheService.getSetting<bool>('location_enabled', true) ?? true;
    autoBackupEnabled.value = _cacheService.getSetting<bool>('auto_backup_enabled', true) ?? true;
    dataSync.value = _cacheService.getSetting<bool>('data_sync', true) ?? true;
    language.value = _cacheService.getLanguage();
    currency.value = _cacheService.getSetting<String>('currency', 'USD') ?? 'USD';
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
    await _cacheService.saveSetting('notifications_enabled', value);

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
    await _cacheService.saveSetting('push_notifications_enabled', value);

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
    await _cacheService.saveSetting('email_notifications_enabled', value);
    _showSettingUpdatedSnackbar('Email notifications ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleSmsNotifications(bool value) async {
    if (!notificationsEnabled.value && value) {
      _showErrorSnackbar('Please enable notifications first');
      return;
    }

    smsNotificationsEnabled.value = value;
    await _cacheService.saveSetting('sms_notifications_enabled', value);
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
    await _cacheService.saveSetting('location_enabled', value);
    _showSettingUpdatedSnackbar('Location services ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleAutoBackup(bool value) async {
    autoBackupEnabled.value = value;
    await _cacheService.saveSetting('auto_backup_enabled', value);
    _showSettingUpdatedSnackbar('Auto backup ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> toggleDataSync(bool value) async {
    dataSync.value = value;
    await _cacheService.saveSetting('data_sync', value);
    _showSettingUpdatedSnackbar('Data sync ${value ? 'enabled' : 'disabled'}');
  }

  Future<void> setLanguage(String languageCode) async {
    language.value = languageCode;
    await _cacheService.saveLanguage(languageCode);

    final languageName = availableLanguages.firstWhere((lang) => lang['code'] == languageCode)['name'];

    _showSettingUpdatedSnackbar('Language changed to $languageName');

    // Update app locale
    final locale = Locale(languageCode);
    Get.updateLocale(locale);
  }

  Future<void> setCurrency(String currencyCode) async {
    currency.value = currencyCode;
    await _cacheService.saveSetting('currency', currencyCode);

    final currencyName = availableCurrencies.firstWhere((curr) => curr['code'] == currencyCode)['name'];

    _showSettingUpdatedSnackbar('Currency changed to $currencyName');
  }

  Future<void> clearCache() async {
    try {
      await _cacheService.clearAllCache();
      _showSuccessSnackbar('Cache cleared successfully');
    } catch (e) {
      _showErrorSnackbar('Failed to clear cache: $e');
    }
  }

  Future<void> exportData() async {
    try {
      // Implementation for data export
      _showSuccessSnackbar('Data export started. You will be notified when complete.');
    } catch (e) {
      _showErrorSnackbar('Failed to export data: $e');
    }
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

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
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

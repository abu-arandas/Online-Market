import '/exports.dart';

class ThemeController extends GetxController {
  final CacheService _cacheService = Get.find<CacheService>();
  // Observable variables
  final themeMode = ThemeMode.system.obs;
  final isDarkMode = false.obs;
  final Rx<Color> primaryColor = Colors.green.obs;
  final Rx<Color> accentColor = Colors.greenAccent.obs;

  // Available theme colors
  final availableColors = <Color>[
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreferences();
    _listenToSystemTheme();
  }

  void _loadThemePreferences() {
    // Load saved theme mode
    final savedThemeMode = _cacheService.getThemeMode();
    themeMode.value = savedThemeMode;

    // Load saved colors
    final savedPrimaryColor = _cacheService.getSetting<int>('primary_color');
    if (savedPrimaryColor != null) {
      primaryColor.value = Color(savedPrimaryColor);
    }

    final savedAccentColor = _cacheService.getSetting<int>('accent_color');
    if (savedAccentColor != null) {
      accentColor.value = Color(savedAccentColor);
    }

    _updateDarkModeStatus();
  }

  void _listenToSystemTheme() {
    // Listen to system theme changes
    ever(themeMode, (_) => _updateDarkModeStatus());
  }

  void _updateDarkModeStatus() {
    switch (themeMode.value) {
      case ThemeMode.dark:
        isDarkMode.value = true;
        break;
      case ThemeMode.light:
        isDarkMode.value = false;
        break;
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        isDarkMode.value = brightness == Brightness.dark;
        break;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _cacheService.saveThemeMode(mode);
    Get.changeThemeMode(mode);

    Get.snackbar(
      'Theme Updated',
      'Theme mode changed to ${_getThemeModeString(mode)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDarkMode.value ? Colors.grey[800] : Colors.grey[200],
      colorText: isDarkMode.value ? Colors.white : Colors.black,
      duration: const Duration(seconds: 2),
    );
  }

  String _getThemeModeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> setPrimaryColor(Color color) async {
    primaryColor.value = color;
    await _cacheService.saveSetting('primary_color', color.toARGB32());

    // Update app theme with new color
    _updateAppTheme();

    Get.snackbar(
      'Color Updated',
      'Primary color has been changed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> setAccentColor(Color color) async {
    accentColor.value = color;
    await _cacheService.saveSetting('accent_color', color.value);

    // Update app theme with new color
    _updateAppTheme();

    Get.snackbar(
      'Accent Color Updated',
      'Accent color has been changed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _updateAppTheme() {
    // Create new themes with updated colors
    final lightTheme = _createLightTheme();
    final darkTheme = _createDarkTheme();

    // Update app themes
    Get.changeTheme(lightTheme);
    // Note: You might need to restart the app for full theme changes
  }

  ThemeData _createLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(primaryColor.value),
      primaryColor: primaryColor.value,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor.value,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  ThemeData _createDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(primaryColor.value),
      primaryColor: primaryColor.value,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor.value,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.value.withOpacity(0.8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor.value,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor.value,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.toARGB32(), swatch);
  }

  Future<void> resetToDefaults() async {
    themeMode.value = ThemeMode.system;
    primaryColor.value = Colors.green;
    accentColor.value = Colors.greenAccent;

    await _cacheService.saveThemeMode(ThemeMode.system);
    await _cacheService.saveSetting('primary_color', Colors.green.value);
    await _cacheService.saveSetting('accent_color', Colors.greenAccent.value);

    Get.changeThemeMode(ThemeMode.system);
    _updateAppTheme();

    Get.snackbar(
      'Theme Reset',
      'Theme has been reset to defaults',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void showThemeSelector() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode.value ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System'),
              trailing: themeMode.value == ThemeMode.system ? Icon(Icons.check, color: primaryColor.value) : null,
              onTap: () {
                setThemeMode(ThemeMode.system);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: themeMode.value == ThemeMode.light ? Icon(Icons.check, color: primaryColor.value) : null,
              onTap: () {
                setThemeMode(ThemeMode.light);
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: themeMode.value == ThemeMode.dark ? Icon(Icons.check, color: primaryColor.value) : null,
              onTap: () {
                setThemeMode(ThemeMode.dark);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void showColorPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode.value ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Primary Color',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode.value ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: availableColors.map((color) {
                final isSelected = color.value == primaryColor.value.value;
                return GestureDetector(
                  onTap: () {
                    setPrimaryColor(color);
                    Get.back();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

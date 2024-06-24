import '/exports.dart';

class ThemeController extends GetxController {
  static ThemeController instance = Get.find();

  bool isDark = false;

  void setThemeMode() {
    isDark = !isDark;
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);

    update();
  }

  void savedThemeMode() {
    bool theme = Get.isDarkMode ? true : false;
    isDark = theme;
    Get.changeThemeMode(theme ? ThemeMode.dark : ThemeMode.light);

    update();
  }

  ThemeData themeData(context, Brightness brightness) => ThemeData(
        useMaterial3: true,
        fontFamily: 'DM Sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF540804),
          brightness: brightness,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF540804),
        ),
        appBarTheme: AppBarTheme(
          toolbarHeight: 100,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: const Color(0xFF540804),
          unselectedItemColor:
              brightness == Brightness.light ? Colors.black : Colors.white,
        ),
        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(shape: CircleBorder()),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.focused) ||
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed) ||
                      states.contains(WidgetState.selected)
                  ? Colors.white
                  : const Color(0xFF540804),
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.focused) ||
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed) ||
                      states.contains(WidgetState.selected)
                  ? const Color(0xFF540804)
                  : Colors.white,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            side: WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.focused) ||
                        states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.pressed) ||
                        states.contains(WidgetState.selected)
                    ? Colors.white
                    : const Color(0xFF540804),
              ),
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.focused) ||
                      states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed) ||
                      states.contains(WidgetState.selected)
                  ? Colors.white
                  : const Color(0xFF540804),
            ),
          ),
        ),
      );
}

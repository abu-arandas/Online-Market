import '/exports.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        title: 'Online Market',
        debugShowCheckedModeBanner: false,
        theme: ThemeController().themeData(context, Brightness.light),
        darkTheme: ThemeController().themeData(context, Brightness.dark),
        themeMode: ThemeController().isDark ? ThemeMode.dark : ThemeMode.light,
        initialBinding: BindingsBuilder(() {
          Get.put<LanguageController>(LanguageController());
          Get.put<ThemeController>(ThemeController());
          Get.put<AuthenticationController>(AuthenticationController());
        }),
        home: const SplashScreen(),
      );
}

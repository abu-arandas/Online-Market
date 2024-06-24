import '/exports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => FlutterBootstrap5(
        builder: (context) => GetMaterialApp(
            title: 'Online Market',
            debugShowCheckedModeBanner: false,
            theme: ThemeController().themeData(context, Brightness.light),
            darkTheme: ThemeController().themeData(context, Brightness.dark),
            themeMode: ThemeController().isDark ? ThemeMode.dark : ThemeMode.light,
            initialBinding: BindingsBuilder(() {
              Get.put<LanguageController>(LanguageController());
              Get.put<ThemeController>(ThemeController());
              Get.put<HomeController>(HomeController());
              Get.put<AddressController>(AddressController());
              Get.put<CartController>(CartController());
            }),
            home: const SplashScreen(),
          ),
  );
}

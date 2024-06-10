import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/language.dart';
import 'view/splash.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        title: 'Online Market',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialBinding: BindingsBuilder(() {
          Get.put<LanguageController>(LanguageController());
        }),
        home: const SplashScreen(),
      );
}

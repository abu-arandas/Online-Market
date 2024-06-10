import 'package:flutter/material.dart';

import '../controller/language.dart';
import '../model/text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool animated = false;

  @override
  void initState() {
    super.initState();

    if (mounted) {
      Future.delayed(
        const Duration(seconds: 3),
        () => setState(() => animated = true),
      );

      /*Future.delayed(
        const Duration(seconds: 10),
        () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Main()),
          (route) => false,
        ),
      );*/
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  text(
                    text: TextString(en: 'Online', ar: 'المتجر'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 48),
                  ),
                  const Text(
                    ' ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 48),
                  ),
                  text(
                    text: TextString(en: 'Market', ar: 'الالكتروني'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              AnimatedOpacity(
                opacity: animated ? 1 : 0,
                duration: const Duration(seconds: 3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

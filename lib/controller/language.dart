import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/model/text.dart';

class LanguageController extends GetxController {
  Locale language = const Locale('en', 'US');

  void changeLanguage() {
    language = language.languageCode == 'en'
        ? const Locale('ar', 'JO')
        : const Locale('en', 'US');

    update();
  }
}

Widget text({
  required TextString text,
  TextStyle? style,
  TextAlign? textAlign,
  int? maxLines,
}) =>
    GetBuilder<LanguageController>(
      builder: (controller) => Text(
        controller.language.languageCode == 'en' ? text.en : text.ar,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
      ),
    );

import '/exports.dart';

class LanguageController extends GetxController {
  static LanguageController instance = Get.find();

  Locale language = const Locale('en', 'US');

  void changeLanguage(Locale? value) {
    language = value ?? const Locale('en', 'US');

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

String textString(TextString text) =>
    LanguageController.instance.language.languageCode == 'en'
        ? text.en
        : text.ar;

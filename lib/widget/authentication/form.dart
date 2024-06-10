import '/exports.dart';

class AuthenticationForm extends StatelessWidget {
  final TextString title, subTitle;
  final Widget child;

  const AuthenticationForm({
    super.key,
    required this.title,
    required this.subTitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Spacer(),
            text(
              text: title,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                height: 0.99,
              ),
            ),
            const SizedBox(height: 16),
            text(text: subTitle),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
            const SizedBox(height: 16),
            const Spacer(flex: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                text(
                  text: TextString(
                    en: 'Designed by: ',
                    ar: 'تم تصميمه بواسطة: ',
                  ),
                ),
                InkWell(
                  onTap: () {}, // TODO
                  child: text(
                    text: TextString(en: 'Ehab Arandas', ar: 'ايهاب عرندس'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GetBuilder<LanguageController>(
                  builder: (controller) => DropdownButton(
                    value: controller.language,
                    padding: const EdgeInsets.all(8),
                    items: const [
                      DropdownMenuItem(
                        value: Locale('ar', 'JO'),
                        child: Text('العربية'),
                      ),
                      DropdownMenuItem(
                        value: Locale('en', 'US'),
                        child: Text('English'),
                      )
                    ],
                    onChanged: controller.changeLanguage,
                  ),
                ),
                GetBuilder<ThemeController>(
                  builder: (controller) => Switch(
                    value: controller.isDark,
                    onChanged: (value) => controller.setThemeMode(),
                    thumbIcon: MaterialStatePropertyAll(
                      Icon(
                        controller.isDark ? Icons.light_mode : Icons.dark_mode,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

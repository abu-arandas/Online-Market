import '/exports.dart';

class HomeController extends GetxController {
  static HomeController instance = Get.find();

  UserModel? user;

  int selectedPage = 0;
  String? shpoCategoryId;

  List<PreferredSizeWidget> appBars(context) => [
        AppBar(
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            title: text(
              text: DateTime.now().hour > 12
                  ? TextString(
                      en: 'Good afternoon',
                      ar: 'مساء الخير',
                    )
                  : TextString(
                      en: 'Good morning',
                      ar: 'صباح الخير',
                    ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            subtitle: Text(
              user!.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            // Language
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
                  ),
                ],
                onChanged: controller.changeLanguage,
              ),
            ),

            // Theme
            GetBuilder<ThemeController>(
              builder: (controller) => Switch(
                value: controller.isDark,
                onChanged: (value) => controller.setThemeMode(),
                thumbIcon: WidgetStatePropertyAll(
                  Icon(
                    controller.isDark ? Icons.light_mode : Icons.dark_mode,
                  ),
                ),
              ),
            ),

            // Favorites
            StreamBuilder(
              stream: favorites(),
              builder: (context, snapshot) {
                return IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoriteScreen(),
                    ),
                  ),
                  icon: Icon(
                    snapshot.hasData && snapshot.data!.isNotEmpty
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: snapshot.hasData && snapshot.data!.isNotEmpty
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                );
              },
            ),

            // Sign Out
            IconButton(
              onPressed: () {
                try {
                  FirebaseAuth.instance
                      .signOut()
                      .then((value) => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                            (route) => false,
                          ))
                      .then(
                        (value) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: text(
                              text: TextString(
                                en: 'Good Bye',
                                ar: 'الى اللقاء',
                              ),
                            ),
                          ),
                        ),
                      );
                } on FirebaseAuthException catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error.message.toString(),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        AppBar(
          title: text(text: TextString(en: 'Our Shop', ar: 'متجرنا')),
        ),
        AppBar(
          title: text(text: TextString(en: 'Cart', ar: 'عربة التسوق')),
        ),
        AppBar(
          title: text(text: TextString(en: 'Orders', ar: 'الطلبات')),
        ),
        AppBar(
          title: text(text: TextString(en: 'Profile', ar: 'الملف الشخصي')),
        ),
      ];
  List<Widget> pages = const [Home(), Shop(), Cart(), Orders()];

  Widget icon({required IconData icon, required int index}) =>
      index == selectedPage
          ? IconButton.outlined(
              onPressed: () => changePage(index),
              icon: Icon(icon),
            )
          : IconButton(
              onPressed: () => changePage(index),
              icon: Icon(icon),
            );

  void changePage(int index) {
    selectedPage = index;
    update();
  }

  @override
  void onInit() {
    super.onInit();

    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) => user = UserModel.fromJson(value));
      } else {
        user = null;
      }
      update();
    });
  }
}

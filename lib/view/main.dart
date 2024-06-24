import '/exports.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GetBuilder<HomeController>(
              builder: (controller) {
                return Scaffold(
                  appBar: controller.appBars(context)[controller.selectedPage],
                  body: controller.pages[controller.selectedPage],
                  bottomNavigationBar: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 2.5,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        controller.icon(icon: Icons.home, index: 0),
                        controller.icon(icon: Icons.shop, index: 1),
                        controller.icon(icon: Icons.shopping_cart, index: 2),
                        controller.icon(icon: Icons.history, index: 3),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text(snapshot.error.toString())),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: context.width,
                  height: context.height,
                  child: Stack(
                    children: [
                      Positioned(
                        width: MediaQuery.sizeOf(context).width * 1.7,
                        bottom: 200,
                        left: 100,
                        child: Image.asset('assets/images/Spline.png'),
                      ),
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 10),
                          child: const SizedBox(),
                        ),
                      ),
                      Positioned.fill(
                        child: SafeArea(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: [
                                    Tab(
                                      text: textString(
                                        TextString(
                                          en: 'Login',
                                          ar: 'تسجيل الدخول',
                                        ),
                                      ),
                                    ),
                                    Tab(
                                      text: textString(
                                        TextString(
                                          en: 'Register',
                                          ar: 'مستخدم جديد',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Expanded(
                                  child: TabBarView(
                                    children: [
                                      LoginForm(),
                                      RegisterForm(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      );
}
/*
[
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home),
                      label: textString(
                        TextString(en: 'Home', ar: 'الصفحة الرئيسية'),
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.shop),
                      label: textString(
                        TextString(en: 'Shop', ar: 'المتجر'),
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.shopping_cart),
                      label: textString(
                        TextString(en: 'Cart', ar: 'عربة التسوق'),
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.history),
                      label: textString(
                        TextString(en: 'Orders', ar: 'الطلبات'),
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Badge(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        label: const Icon(
                          Icons.info,
                          size: 10,
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.person),
                      ),
                      label: textString(
                        TextString(en: 'Profile', ar: 'الملف الشخصي'),
                      ),
                    ),
                  ]*/
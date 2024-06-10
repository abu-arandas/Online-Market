import '/exports.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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

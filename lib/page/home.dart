import '/exports.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<AuthenticationController>(
        builder: (controller) => const AuthenticationScreen(),
      );
}

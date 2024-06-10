import '/exports.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController instance = Get.find();

  UserModel? currentUser;

  void login() {}

  void logout() {
    currentUser = null;
    update();
  }

  void register() {}
}

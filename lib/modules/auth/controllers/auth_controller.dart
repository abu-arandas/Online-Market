import '/exports.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Observables
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _initAuth();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Initialize authentication
  void _initAuth() {
    // Listen to auth state changes
    _authRepository.authStateChanges().listen((user) {
      if (user != null) {
        _getCurrentUser();
      } else {
        currentUser.value = null;
        isLoggedIn.value = false;
      }
    });

    // Check if user is already logged in
    _getCurrentUser();
  }

  // Get current user
  Future<void> _getCurrentUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        isLoggedIn.value = true;
      }
    } catch (e) {
      AppHelpers.showSnackBar('Failed to get user data', isError: true);
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final user = await _authRepository.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      currentUser.value = user;
      isLoggedIn.value = true;

      AppHelpers.showSnackBar(AppConstants.loginSuccess);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Create user account
  Future<void> createUserWithEmailAndPassword() async {
    if (!signupFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final user = await _authRepository.createUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
      );

      currentUser.value = user;
      isLoggedIn.value = true;

      AppHelpers.showSnackBar(AppConstants.signupSuccess);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      await _authRepository.sendPasswordResetEmail(emailController.text.trim());

      AppHelpers.showSnackBar('Password reset email sent successfully');
      Get.back();
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      await _authRepository.signOut();

      currentUser.value = null;
      isLoggedIn.value = false;

      // Clear form controllers
      _clearControllers();

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      isLoading.value = true;

      final user = await _authRepository.updateUserProfile(updatedUser);
      currentUser.value = user;

      AppHelpers.showSnackBar(AppConstants.profileUpdated);
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Upload profile image
  Future<void> uploadProfileImage(Uint8List imageBytes) async {
    try {
      isLoading.value = true;

      final imageUrl = await _authRepository.uploadProfileImage(
        imageBytes,
        currentUser.value!.id,
      );

      final updatedUser = currentUser.value!.copyWith(profileImageUrl: imageUrl);
      await updateUserProfile(updatedUser);
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
      AppHelpers.showSnackBar('Verification email sent');
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    }
  }

  // Clear form controllers
  void _clearControllers() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
  }

  // Navigation methods
  void goToLogin() {
    _clearControllers();
    Get.toNamed(AppRoutes.login);
  }

  void goToSignup() {
    _clearControllers();
    Get.toNamed(AppRoutes.signup);
  }

  void goToForgotPassword() {
    _clearControllers();
    Get.toNamed(AppRoutes.forgotPassword);
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emailRequired;
    }
    if (!AppHelpers.isValidEmail(value)) {
      return AppConstants.emailInvalid;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    }
    if (!AppHelpers.isValidPassword(value)) {
      return AppConstants.passwordTooShort;
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.nameRequired;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}

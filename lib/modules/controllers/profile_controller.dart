import '/exports.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Observables
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Form key
  final profileFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _initializeProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Initialize profile
  void _initializeProfile() {
    final authController = Get.find<AuthController>();
    user.value = authController.currentUser.value;
    _populateFields();
  }

  // Populate form fields
  void _populateFields() {
    if (user.value != null) {
      nameController.text = user.value!.name;
      emailController.text = user.value!.email;
      phoneController.text = user.value!.phone ?? '';
    }
  }

  // Update profile
  Future<void> updateProfile() async {
    if (!profileFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final updatedUser = user.value!.copyWith(
        name: nameController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await _authRepository.updateUserProfile(updatedUser);
      user.value = updatedUser;

      // Update auth controller
      final authController = Get.find<AuthController>();
      authController.currentUser.value = updatedUser;

      AppHelpers.showSnackBar(AppConstants.profileUpdated);
    } catch (e) {
      AppHelpers.showSnackBar(e.toString(), isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  // Upload profile image
  Future<void> uploadProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        isLoading.value = true;

        final bytes = await pickedFile.readAsBytes();
        final imageUrl = await _authRepository.uploadProfileImage(bytes, user.value!.id);

        final updatedUser = user.value!.copyWith(
          profileImageUrl: imageUrl,
          updatedAt: DateTime.now(),
        );

        await _authRepository.updateUserProfile(updatedUser);
        user.value = updatedUser;

        // Update auth controller
        final authController = Get.find<AuthController>();
        authController.currentUser.value = updatedUser;

        AppHelpers.showSnackBar('Profile picture updated successfully');
      }
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

  // Sign out
  Future<void> signOut() async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
    );

    if (confirmed) {
      final authController = Get.find<AuthController>();
      await authController.signOut();
    }
  }

  // Navigation methods
  void goToOrders() {
    Get.toNamed(AppRoutes.orders);
  }

  void goToAddresses() {
    Get.toNamed(AppRoutes.addresses);
  }

  void goToSettings() {
    Get.toNamed(AppRoutes.settings);
  }

  void goToSupport() {
    Get.toNamed(AppRoutes.support);
  }

  void goToAbout() {
    Get.toNamed(AppRoutes.about);
  }

  // Validation methods
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.nameRequired;
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty && !AppHelpers.isValidPhone(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Helper methods
  String get userInitials {
    if (user.value?.name.isNotEmpty == true) {
      final nameParts = user.value!.name.split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      }
      return user.value!.name[0].toUpperCase();
    }
    return 'U';
  }

  bool get hasProfileImage => user.value?.profileImageUrl?.isNotEmpty == true;

  String get memberSince {
    if (user.value?.createdAt != null) {
      return AppHelpers.formatDate(user.value!.createdAt);
    }
    return 'Unknown';
  }
}

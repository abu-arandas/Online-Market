import '/exports.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Form(
            key: controller.signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Text
                _buildWelcomeText(),
                const SizedBox(height: AppConstants.spacing32),

                // Name Field
                CustomInput(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  validator: controller.validateName,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                const SizedBox(height: AppConstants.spacing16),

                // Email Field
                CustomInput(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: AppConstants.spacing16),

                // Password Field
                CustomInput(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: controller.passwordController,
                  obscureText: true,
                  validator: controller.validatePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: AppConstants.spacing16),

                // Confirm Password Field
                CustomInput(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: controller.confirmPasswordController,
                  obscureText: true,
                  validator: controller.validateConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // Sign Up Button
                Obx(() => CustomButton(
                      text: 'Create Account',
                      onPressed: controller.createUserWithEmailAndPassword,
                      isLoading: controller.isLoading.value,
                      width: double.infinity,
                    )),
                const SizedBox(height: AppConstants.spacing24),

                // Login Link
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Join Online Market',
          style: AppConstants.headingLarge.copyWith(
            color: AppConstants.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing8),
        Text(
          'Create your account to start shopping',
          style: AppConstants.bodyLarge.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: AppConstants.bodyMedium,
        ),
        TextButton(
          onPressed: controller.goToLogin,
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}

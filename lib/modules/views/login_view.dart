import '/exports.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Form(
            key: controller.loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spacing48),

                // Logo
                _buildLogo(),
                const SizedBox(height: AppConstants.spacing48),

                // Welcome Text
                _buildWelcomeText(),
                const SizedBox(height: AppConstants.spacing32),

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
                const SizedBox(height: AppConstants.spacing8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: controller.goToForgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // Login Button
                Obx(() => CustomButton(
                      text: 'Login',
                      onPressed: controller.signInWithEmailAndPassword,
                      isLoading: controller.isLoading.value,
                      width: double.infinity,
                    )),
                const SizedBox(height: AppConstants.spacing24),

                // Sign Up Link
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
        ),
        child: const Icon(
          Icons.shopping_cart,
          size: 60,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back!',
          style: AppConstants.headingLarge.copyWith(
            color: AppConstants.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing8),
        Text(
          'Sign in to continue shopping',
          style: AppConstants.bodyLarge.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an account? ',
          style: AppConstants.bodyMedium,
        ),
        TextButton(
          onPressed: controller.goToSignup,
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}

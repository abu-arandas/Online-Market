import '/exports.dart';

class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing24),
          child: Form(
            key: controller.forgotPasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.spacing48),

                // Icon
                _buildIcon(),
                const SizedBox(height: AppConstants.spacing32),

                // Instructions
                _buildInstructions(),
                const SizedBox(height: AppConstants.spacing32),

                // Email Field
                CustomInput(
                  label: 'Email',
                  hint: 'Enter your email address',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: AppConstants.spacing24),

                // Send Reset Email Button
                Obx(() => CustomButton(
                      text: 'Send Reset Email',
                      onPressed: controller.sendPasswordResetEmail,
                      isLoading: controller.isLoading.value,
                      width: double.infinity,
                    )),
                const SizedBox(height: AppConstants.spacing24),

                // Back to Login Link
                _buildBackToLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
        ),
        child: const Icon(
          Icons.lock_reset,
          size: 50,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        Text(
          'Forgot Your Password?',
          style: AppConstants.headingMedium.copyWith(
            color: AppConstants.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacing12),
        Text(
          'Enter your email address below and we\'ll send you a link to reset your password.',
          style: AppConstants.bodyMedium.copyWith(
            color: AppConstants.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBackToLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Remember your password? ',
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

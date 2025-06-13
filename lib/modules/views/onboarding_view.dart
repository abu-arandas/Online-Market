import '/exports.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60), // For centering
                  Obx(() => Row(
                        children: List.generate(
                          controller.pages.length,
                          (index) => _buildDot(index),
                        ),
                      )),
                  TextButton(
                    onPressed: controller.skip,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.updateCurrentPage,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  final page = controller.pages[index];
                  return _buildPage(page);
                },
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing20),
              child: Obx(() => Row(
                    children: [
                      // Previous Button
                      if (controller.currentPage.value > 0)
                        Expanded(
                          child: CustomButton(
                            text: 'Previous',
                            onPressed: controller.previousPage,
                            isOutlined: true,
                          ),
                        ),

                      if (controller.currentPage.value > 0) const SizedBox(width: AppConstants.spacing16),

                      // Next/Get Started Button
                      Expanded(
                        flex: controller.currentPage.value == 0 ? 1 : 1,
                        child: CustomButton(
                          text: controller.isLastPage ? 'Get Started' : 'Next',
                          onPressed: controller.isLastPage ? controller.completeOnboarding : controller.nextPage,
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Obx(() => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.currentPage.value == index ? AppConstants.primaryColor : Colors.grey[300],
          ),
        ));
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration/Image
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              color: page.color.withValues(alpha: 0.1),
            ),
            child: page.imagePath.isNotEmpty
                ? Image.asset(
                    page.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        page.icon,
                        size: 120,
                        color: page.color,
                      );
                    },
                  )
                : Icon(
                    page.icon,
                    size: 120,
                    color: page.color,
                  ),
          ),
          const SizedBox(height: AppConstants.spacing32),

          // Title
          Text(
            page.title,
            style: AppConstants.headingLarge.copyWith(
              color: AppConstants.textPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),

          // Description
          Text(
            page.description,
            style: AppConstants.bodyLarge.copyWith(
              color: AppConstants.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Special content for specific pages
          if (page.type == OnboardingPageType.permissions) _buildPermissionsContent(),
          if (page.type == OnboardingPageType.notifications) _buildNotificationsContent(),
        ],
      ),
    );
  }

  Widget _buildPermissionsContent() {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacing24),
      child: Column(
        children: [
          _buildPermissionItem(
            icon: Icons.location_on,
            title: 'Location Access',
            description: 'To provide accurate delivery estimates',
            isRequired: true,
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildPermissionItem(
            icon: Icons.camera_alt,
            title: 'Camera Access',
            description: 'To scan barcodes and upload photos',
            isRequired: false,
          ),
          const SizedBox(height: AppConstants.spacing12),
          _buildPermissionItem(
            icon: Icons.notifications,
            title: 'Notifications',
            description: 'To keep you updated about your orders',
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 24,
          ),
          const SizedBox(width: AppConstants.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppConstants.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: AppConstants.spacing4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.errorColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Text(
                          'Required',
                          style: AppConstants.bodySmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  description,
                  style: AppConstants.bodySmall.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacing24),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: AppConstants.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.notifications_active,
              color: AppConstants.primaryColor,
              size: 32,
            ),
            const SizedBox(height: AppConstants.spacing12),
            Text(
              'Stay Updated',
              style: AppConstants.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacing8),
            Text(
              'Get notified about order updates, special offers, and delivery status',
              style: AppConstants.bodyMedium.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacing16),
            CustomButton(
              text: 'Enable Notifications',
              onPressed: controller.enableNotifications,
              backgroundColor: AppConstants.primaryColor,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

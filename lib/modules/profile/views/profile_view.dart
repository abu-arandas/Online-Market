import '/exports.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: controller.goToSettings,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing16),
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),
              const SizedBox(height: AppConstants.spacing24),

              // Profile Form
              _buildProfileForm(),
              const SizedBox(height: AppConstants.spacing24),

              // Menu Items
              _buildMenuItems(),
              const SizedBox(height: AppConstants.spacing24),

              // Sign Out Button
              _buildSignOutButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return CustomCard(
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              Obx(() => CircleAvatar(
                    radius: 50,
                    backgroundColor: AppConstants.primaryColor,
                    backgroundImage:
                        controller.hasProfileImage ? NetworkImage(controller.user.value!.profileImageUrl!) : null,
                    child: !controller.hasProfileImage
                        ? Text(
                            controller.userInitials,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  )),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: controller.uploadProfileImage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacing16),

          // User Info
          Obx(() => Column(
                children: [
                  Text(
                    controller.user.value?.name ?? 'User',
                    style: AppConstants.headingMedium,
                  ),
                  const SizedBox(height: AppConstants.spacing4),
                  Text(
                    controller.user.value?.email ?? '',
                    style: AppConstants.bodyMedium.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacing8),

                  // Email Verification Status
                  if (controller.user.value?.isEmailVerified == false)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.warning,
                          color: AppConstants.warningColor,
                          size: 16,
                        ),
                        const SizedBox(width: AppConstants.spacing4),
                        Text(
                          'Email not verified',
                          style: AppConstants.bodySmall.copyWith(
                            color: AppConstants.warningColor,
                          ),
                        ),
                        TextButton(
                          onPressed: controller.sendEmailVerification,
                          child: const Text('Verify'),
                        ),
                      ],
                    ),

                  Text(
                    'Member since ${controller.memberSince}',
                    style: AppConstants.bodySmall.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return CustomCard(
      child: Form(
        key: controller.profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: AppConstants.headingSmall,
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Name Field
            CustomInput(
              label: 'Full Name',
              controller: controller.nameController,
              validator: controller.validateName,
              prefixIcon: const Icon(Icons.person_outlined),
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Email Field (Read-only)
            CustomInput(
              label: 'Email',
              controller: controller.emailController,
              readOnly: true,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: AppConstants.spacing16),

            // Phone Field
            CustomInput(
              label: 'Phone Number',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              validator: controller.validatePhone,
              prefixIcon: const Icon(Icons.phone_outlined),
              hint: 'Optional',
            ),
            const SizedBox(height: AppConstants.spacing24),

            // Update Button
            Obx(() => CustomButton(
                  text: 'Update Profile',
                  onPressed: controller.updateProfile,
                  isLoading: controller.isLoading.value,
                  width: double.infinity,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {
        'title': 'My Orders',
        'subtitle': 'View your order history',
        'icon': Icons.shopping_bag_outlined,
        'onTap': controller.goToOrders,
      },
      {
        'title': 'Delivery Addresses',
        'subtitle': 'Manage your delivery addresses',
        'icon': Icons.location_on_outlined,
        'onTap': controller.goToAddresses,
      },
      {
        'title': 'Help & Support',
        'subtitle': 'Get help or contact support',
        'icon': Icons.help_outline,
        'onTap': controller.goToSupport,
      },
      {
        'title': 'About',
        'subtitle': 'App version and information',
        'icon': Icons.info_outline,
        'onTap': controller.goToAbout,
      },
    ];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu',
            style: AppConstants.headingSmall,
          ),
          const SizedBox(height: AppConstants.spacing16),
          ...menuItems.map((item) => _buildMenuItem(
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                icon: item['icon'] as IconData,
                onTap: item['onTap'] as VoidCallback,
              )),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: AppConstants.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppConstants.bodySmall.copyWith(
          color: AppConstants.textSecondaryColor,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppConstants.textSecondaryColor,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSignOutButton() {
    return CustomButton(
      text: 'Sign Out',
      onPressed: controller.signOut,
      isOutlined: true,
      backgroundColor: AppConstants.errorColor,
      textColor: AppConstants.errorColor,
      width: double.infinity,
    );
  }
}

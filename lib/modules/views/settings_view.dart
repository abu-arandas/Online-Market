import '/exports.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSettings(),
            const SizedBox(height: 24),
            _buildSecuritySettings(),
            const SizedBox(height: 24),
            _buildAppPreferences(),
            const SizedBox(height: 24),
            _buildDataSettings(),
            const SizedBox(height: 24),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        Obx(() => SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive notifications from the app'),
              value: controller.notificationsEnabled.value,
              onChanged: controller.toggleNotifications,
            )),
        Obx(() => SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Get notified about orders, offers, and updates'),
              value: controller.pushNotificationsEnabled.value,
              onChanged: controller.notificationsEnabled.value ? controller.togglePushNotifications : null,
            )),
        Obx(() => SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive notifications via email'),
              value: controller.emailNotificationsEnabled.value,
              onChanged: controller.notificationsEnabled.value ? controller.toggleEmailNotifications : null,
            )),
        Obx(() => SwitchListTile(
              title: const Text('SMS Notifications'),
              subtitle: const Text('Receive important updates via SMS'),
              value: controller.smsNotificationsEnabled.value,
              onChanged: controller.notificationsEnabled.value ? controller.toggleSmsNotifications : null,
            )),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return _buildSettingsSection(
      title: 'Security',
      icon: Icons.security,
      children: [
        Obx(() => SwitchListTile(
              title: const Text('Biometric Login'),
              subtitle: const Text('Use fingerprint or face ID to login'),
              value: controller.biometricEnabled.value,
              onChanged: controller.toggleBiometric,
            )),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Change Password'),
          subtitle: const Text('Update your account password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Get.toNamed('/change-password'),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Get.toNamed('/privacy-policy'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Get.toNamed('/terms-of-service'),
        ),
      ],
    );
  }

  Widget _buildAppPreferences() {
    return _buildSettingsSection(
      title: 'App Preferences',
      icon: Icons.tune,
      children: [
        Obx(() => ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: Text('Current: ${controller.currentLanguageName}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: controller.showLanguageSelector,
            )),
        Obx(() => ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Currency'),
              subtitle: Text('Current: ${controller.currentCurrencyName}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: controller.showCurrencySelector,
            )),
        Obx(() => SwitchListTile(
              title: const Text('Location Services'),
              subtitle: const Text('Allow app to access your location'),
              value: controller.locationEnabled.value,
              onChanged: controller.toggleLocation,
            )),
      ],
    );
  }

  Widget _buildDataSettings() {
    return _buildSettingsSection(
      title: 'Data & Storage',
      icon: Icons.storage,
      children: [
        Obx(() => SwitchListTile(
              title: const Text('Auto Backup'),
              subtitle: const Text('Automatically backup your data'),
              value: controller.autoBackupEnabled.value,
              onChanged: controller.toggleAutoBackup,
            )),
        Obx(() => SwitchListTile(
              title: const Text('Data Sync'),
              subtitle: const Text('Sync data across devices'),
              value: controller.dataSync.value,
              onChanged: controller.toggleDataSync,
            )),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSettingsSection(
      title: 'About',
      icon: Icons.info,
      children: [
        Obx(() => ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: Text('${controller.appVersion.value} (${controller.buildNumber.value})'),
            )),
        ListTile(
          leading: const Icon(Icons.star_rate),
          title: const Text('Rate App'),
          subtitle: const Text('Rate us on the app store'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _rateApp(),
        ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Share App'),
          subtitle: const Text('Recommend to friends'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _shareApp(),
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => Get.toNamed('/help-support'),
        ),
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('Send Feedback'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _sendFeedback(),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return _buildSettingsSection(
      title: 'Danger Zone',
      icon: Icons.warning,
      iconColor: Colors.red,
      children: [
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.orange),
          title: const Text('Sign Out', style: TextStyle(color: Colors.orange)),
          onTap: () => _showSignOutDialog(),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
          subtitle: const Text('Permanently delete your account and data'),
          onTap: () => _showDeleteAccountDialog(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.blue).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? Colors.blue),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor ?? Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              final AuthController authController = Get.find<AuthController>();
              authController.signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? '
          'This action cannot be undone and will remove all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _rateApp() async {
    const url = 'https://play.google.com/store/apps/details?id=com.example.online_market';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareApp() {
    Share.share(
      'Check out this amazing grocery app! Download Online Market now: '
      'https://play.google.com/store/apps/details?id=com.example.online_market',
      subject: 'Online Market - Grocery Shopping App',
    );
  }

  void _sendFeedback() async {
    const email = 'e00arandas@gmail.com';
    const subject = 'Online Market App Feedback';
    const body = 'Hi,\n\nI would like to share my feedback about the Online Market app:\n\n';

    final url = 'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar(
        'Error',
        'Could not open email client',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

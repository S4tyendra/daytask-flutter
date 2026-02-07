import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:day_task/app/routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        final profile = controller.profile.value;
        // Ensure profile is loaded before building UI that depends on it
        if (profile == null && !controller.isLoading.value) {
          return const Center(child: Text("Profile not found"));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildProfileAvatar(context, profile),
              const SizedBox(height: 32),
              _buildProfileInfo(context, profile!),
              const SizedBox(height: 24),
              _buildTaskStats(context),
              const SizedBox(height: 24),
              _buildMenuItems(context),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, profile) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFC107), width: 3),
          ),
          child: CircleAvatar(
            radius: 58,
            backgroundColor: Theme.of(context).cardColor,
            backgroundImage: profile?.avatarUrl != null
                ? NetworkImage(profile!.avatarUrl!)
                : null,
            child: profile?.avatarUrl == null
                ? Text(
                    profile?.initials ?? '?',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC107),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.black, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(BuildContext context, profile) {
    return Column(
      children: [
        _buildInfoCard(
          context,
          icon: Icons.person,
          label: profile?.displayName ?? 'Unknown User',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(context, icon: Icons.email, label: controller.userEmail),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          icon: Icons.lock,
          label: 'Password',
          trailing: Icons.edit,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    IconData? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).cardColor, // Use cardColor instead of hardcoded
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
          ),
          if (trailing != null)
            Icon(
              trailing,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildTaskStats(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() => _buildStatItem(context, 'Total', controller.totalTasks)),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).dividerColor,
          ),
          Obx(
            () =>
                _buildStatItem(context, 'Completed', controller.completedTasks),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).dividerColor,
          ),
          Obx(
            () => _buildStatItem(context, 'Pending', controller.pendingTasks),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: Color(0xFFFFC107),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.list_alt,
          label: 'My Tasks',
          onTap: () => Get.toNamed(Routes.TASK_LIST),
        ),
        _buildThemeToggle(context), // Added Toggle
        _buildMenuItem(
          context,
          icon: Icons.privacy_tip,
          label: 'Privacy',
          trailing: Icons.keyboard_arrow_down,
        ),
        _buildMenuItem(
          context,
          icon: Icons.settings,
          label: 'Setting',
          trailing: Icons.keyboard_arrow_down,
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Adjusted padding for switch
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.brightness_6,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Dark Mode',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
            ),
          ),
          Obx(
            () => Switch(
              value: controller.isDarkMode.value,
              onChanged: (val) => controller.toggleTheme(),
              activeColor: const Color(0xFFFFC107),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    IconData? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
            ),
            if (trailing != null)
              Icon(
                trailing,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: controller.logout,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFC107),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

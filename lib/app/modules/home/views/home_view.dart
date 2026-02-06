import 'package:day_task/app/modules/chat/views/chat_view.dart';
import 'package:day_task/app/modules/dashboard/views/dashboard_view.dart';
import 'package:day_task/app/modules/new_task/views/new_task_view.dart';
import 'package:day_task/app/modules/notifications/views/notifications_view.dart';
import 'package:day_task/app/modules/profile/views/profile_view.dart';
import 'package:day_task/app/modules/schedule/views/schedule_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 600;

        return Scaffold(
          backgroundColor: Get.theme.scaffoldBackgroundColor,
          body: Row(
            children: [
              if (isWideScreen) _buildNavigationRail(),
              Expanded(child: _buildBody()),
            ],
          ),
          bottomNavigationBar: isWideScreen ? null : _buildBottomNavBar(),
        );
      },
    );
  }

  Widget _buildBody() {
    return Obx(() {
      switch (controller.selectedIndex.value) {
        case 0:
          return DashboardView();
        case 1:
          return ChatView();
        case 2:
          return NewTaskView();
        case 3:
          return ScheduleView();
        case 4:
          return NotificationsView();
        default:
          return ProfileView();
      }
    });
  }

  Widget _buildNavigationRail() {
    return Obx(
      () => NavigationRail(
        backgroundColor: Get.theme.colorScheme.surface,
        selectedIndex: controller.selectedIndex.value,
        onDestinationSelected: controller.changeIndex,
        labelType: NavigationRailLabelType.all,
        indicatorColor: Get.theme.colorScheme.primary.withOpacity(0.2),
        selectedIconTheme: IconThemeData(color: Get.theme.colorScheme.primary),
        unselectedIconTheme: IconThemeData(
          color: Get.theme.colorScheme.onSurfaceVariant,
        ),
        selectedLabelTextStyle: TextStyle(
          color: Get.theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Get.theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: FloatingActionButton(
            onPressed: () => controller.changeIndex(2),
            backgroundColor: Get.theme.colorScheme.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
          ),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: Text('Chat'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.add),
            selectedIcon: Icon(Icons.add),
            label: Text('Add'),
            disabled: true,
          ),
          NavigationRailDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: Text('Calendar'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: Text('Notifications'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _bottomNavItem(
                index: 0,
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
              ),
              _bottomNavItem(
                index: 1,
                label: 'Chat',
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
              ),
              _buildAddButton(),
              _bottomNavItem(
                index: 3,
                label: 'Calendar',
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
              ),
              _bottomNavItem(
                index: 4,
                label: 'Notification',
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = controller.selectedIndex.value == index;
    final color = isSelected
        ? Get.theme.colorScheme.primary
        : Get.theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => controller.changeIndex(index),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () => controller.changeIndex(2),
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primary,
          borderRadius: BorderRadius.zero,
        ),
        child: Icon(
          Icons.add,
          color: Get.theme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }
}

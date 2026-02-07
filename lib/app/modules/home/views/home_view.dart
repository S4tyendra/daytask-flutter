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
      Widget currentView;
      switch (controller.selectedIndex.value) {
        case 0:
          currentView = DashboardView();
          break;
        case 1:
          currentView = ChatView();
          break;
        case 2:
          currentView = NewTaskView();
          break;
        case 3:
          currentView = ScheduleView();
          break;
        case 4:
          currentView = NotificationsView();
          break;
        default:
          currentView = ProfileView();
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(controller.selectedIndex.value),
          child: currentView,
        ),
      );
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
              borderRadius: BorderRadius.all(Radius.circular(10)),
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
            // disabled: true,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final isSelected = controller.selectedIndex.value == 2;

    return InkWell(
      onTap: () => controller.changeIndex(2),
      child: AnimatedScale(
        scale: isSelected ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 48,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary,
            borderRadius: BorderRadius.zero,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Get.theme.colorScheme.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: AnimatedRotation(
            turns: isSelected ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Icon(
              Icons.add,
              color: Get.theme.colorScheme.onPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

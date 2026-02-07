import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:day_task/app/routes/app_pages.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: controller.markAllAsRead,
                child: const Text(
                  'Mark all read',
                  style: TextStyle(color: Color(0xFFFFC107)),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Text(
              'No notifications yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView(
          children: [
            if (controller.newNotifications.isNotEmpty) ...[
              _buildSectionHeader('New'),
              ...controller.newNotifications.map(
                (notification) =>
                    _buildNotificationItem(notification, isNew: true),
              ),
            ],
            if (controller.earlierNotifications.isNotEmpty) ...[
              _buildSectionHeader('Earlier'),
              ...controller.earlierNotifications.map(
                (notification) =>
                    _buildNotificationItem(notification, isNew: false),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(notification, {required bool isNew}) {
    return GestureDetector(
      onTap: () {
        controller.markAsRead(notification.id);

        // Navigate based on notification type
        if (notification.metadata != null &&
            notification.metadata!['task_id'] != null) {
          Get.toNamed(
            Routes.TASK_DETAILS,
            arguments: {'taskId': notification.metadata!['task_id']},
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNew
              ? const Color(0xFF34495E).withOpacity(0.8)
              : const Color(0xFF34495E).withOpacity(0.4),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getNotificationColor(notification.type),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${notification.message}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (notification.metadata != null &&
                      notification.metadata!['task_title'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.metadata!['task_title'],
                      style: const TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              notification.timeAgo,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'task_assigned':
        return const Color(0xFF3498DB);
      case 'task_completed':
        return const Color(0xFF2ECC71);
      case 'comment':
        return const Color(0xFF9B59B6);
      case 'mention':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'task_assigned':
        return Icons.assignment;
      case 'task_completed':
        return Icons.check_circle;
      case 'comment':
        return Icons.comment;
      case 'mention':
        return Icons.alternate_email;
      default:
        return Icons.notifications;
    }
  }
}

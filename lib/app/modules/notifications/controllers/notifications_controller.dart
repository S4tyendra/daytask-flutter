import 'package:get/get.dart';
import '../../../services/realtime_service.dart';
import '../../../data/models/notification_model.dart';

class NotificationsController extends GetxController {
  final RealtimeService _realtimeService = Get.find<RealtimeService>();

  RxList<NotificationModel> get notifications => _realtimeService.notifications;
  RxInt get unreadCount => _realtimeService.unreadNotificationCount;

  List<NotificationModel> get newNotifications =>
      notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get earlierNotifications =>
      notifications.where((n) => n.isRead).toList();

  Future<void> markAsRead(String notificationId) async {
    await _realtimeService.markNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _realtimeService.markAllNotificationsAsRead();
  }
}

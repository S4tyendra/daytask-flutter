import 'package:day_task/app/modules/chat/controllers/chat_controller.dart';
import 'package:day_task/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:day_task/app/modules/profile/controllers/profile_controller.dart';
import 'package:day_task/app/modules/schedule/controllers/schedule_controller.dart';
import 'package:get/get.dart';
import 'package:day_task/app/data/services/task_service.dart';
import 'package:day_task/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:day_task/app/modules/new_task/controllers/new_task_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskService>(() => TaskService());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<NewTaskController>(() => NewTaskController());
    Get.lazyPut<ScheduleController>(() => ScheduleController());
    Get.lazyPut<NotificationsController>(() => NotificationsController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ChatController>(() => ChatController());
  }
}

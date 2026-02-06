import 'package:get/get.dart';
import 'package:day_task/app/data/services/task_service.dart';
import '../controllers/task_list_controller.dart';

class TaskListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TaskService>()) {
      Get.put<TaskService>(TaskService());
    }
    Get.lazyPut<TaskListController>(() => TaskListController());
  }
}

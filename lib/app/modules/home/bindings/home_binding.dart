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
  }
}

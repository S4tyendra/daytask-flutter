import 'package:get/get.dart';

import '../controllers/new_task_controller.dart';

class NewTaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewTaskController>(
      () => NewTaskController(),
    );
  }
}

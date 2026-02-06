import 'package:get/get.dart';
import 'package:day_task/app/data/models/task_model.dart';
import 'package:day_task/app/data/services/task_service.dart';

class TaskListController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();

  final tasks = <TaskModel>[].obs;
  final isLoading = true.obs;
  final statusFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    statusFilter.value = args?['status'] ?? '';
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      List<TaskModel> result;
      if (statusFilter.value == 'completed') {
        result = await _taskService.fetchCompletedTasks();
      } else if (statusFilter.value == 'ongoing') {
        result = await _taskService.fetchOngoingTasks();
      } else {
        result = await _taskService.fetchTasks();
      }
      tasks.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String get title {
    switch (statusFilter.value) {
      case 'completed':
        return 'Completed Tasks';
      case 'ongoing':
        return 'Ongoing Tasks';
      default:
        return 'All Tasks';
    }
  }
}

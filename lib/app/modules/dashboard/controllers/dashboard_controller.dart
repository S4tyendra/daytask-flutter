import 'package:get/get.dart';
import 'package:day_task/app/data/models/task_model.dart';
import 'package:day_task/app/data/services/task_service.dart';
import 'package:day_task/app/services/supabase_service.dart';

class DashboardController extends GetxController {
  final TaskService _taskService = Get.put(TaskService());
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final _allCompletedTasks = <TaskModel>[].obs;
  final _allOngoingTasks = <TaskModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;

  List<TaskModel> get completedTasks {
    if (searchQuery.value.isEmpty) return _allCompletedTasks;
    return _allCompletedTasks
        .where(
          (task) =>
              task.title.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              (task.description?.toLowerCase().contains(
                    searchQuery.value.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  List<TaskModel> get ongoingTasks {
    if (searchQuery.value.isEmpty) return _allOngoingTasks;
    return _allOngoingTasks
        .where(
          (task) =>
              task.title.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              (task.description?.toLowerCase().contains(
                    searchQuery.value.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  ProfileModel? get currentUserProfile {
    final user = _supabaseService.currentUser;
    if (user == null) return null;
    return ProfileModel(
      id: user.id,
      fullName: user.userMetadata?['full_name'] ?? user.email?.split('@').first,
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh when returning to dashboard
    ever(searchQuery, (_) {
      // Trigger rebuild when search changes
    });
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      final completed = await _taskService.fetchCompletedTasks();
      final ongoing = await _taskService.fetchOngoingTasks();
      _allCompletedTasks.assignAll(completed);
      _allOngoingTasks.assignAll(ongoing);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTasks() async {
    await fetchTasks();
  }
}

import 'dart:developer';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/task_model.dart';

class ScheduleController extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;

  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      isLoading.value = true;
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _client
          .from('tasks')
          .select('*, task_members!inner(profiles(*))')
          .eq('user_id', userId)
          .not('due_date', 'is', null)
          .order('due_date', ascending: true);

      tasks.value = (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error loading tasks: $e');
      Get.snackbar('Error', 'Failed to load tasks');
    } finally {
      isLoading.value = false;
    }
  }

  List<TaskModel> getTasksForDate(DateTime date) {
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  List<TaskModel> get todayTasks => getTasksForDate(selectedDate.value);

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  List<DateTime> get currentWeek {
    final now = selectedDate.value;
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(
      7,
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }

  String get currentMonthYear {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[selectedDate.value.month - 1];
  }
}

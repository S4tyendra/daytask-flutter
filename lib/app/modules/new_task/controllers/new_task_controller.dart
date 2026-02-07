import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:day_task/app/data/models/task_model.dart';
import 'package:day_task/app/data/services/task_service.dart';
import 'package:day_task/app/modules/home/controllers/home_controller.dart';

class NewTaskController extends GetxController {
  final TaskService _taskService = Get.find<TaskService>();
  final SupabaseClient _client = Supabase.instance.client;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final newSubtaskController = TextEditingController();

  final selectedMembers = <ProfileModel>[].obs;
  final allUsers = <ProfileModel>[].obs;
  final filteredUsers = <ProfileModel>[].obs;
  final searchQuery = ''.obs;

  final subtasks = <String>[].obs; // List of subtask titles

  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();

  final isLoading = false.obs;
  final isSearchingUsers = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllUsers();
    debounce(
      searchQuery,
      (_) => filterUsers(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    newSubtaskController.dispose();
    super.onClose();
  }

  Future<void> loadAllUsers() async {
    try {
      isSearchingUsers.value = true;
      final users = await _taskService.getAllUsers();
      allUsers.assignAll(users);
      filteredUsers.assignAll(users);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: $e');
    } finally {
      isSearchingUsers.value = false;
    }
  }

  void filterUsers() {
    if (searchQuery.value.isEmpty) {
      filteredUsers.assignAll(allUsers);
    } else {
      filteredUsers.assignAll(
        allUsers
            .where(
              (u) => u.displayName.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
            )
            .toList(),
      );
    }
  }

  void addMember(ProfileModel user) {
    if (!selectedMembers.any((m) => m.id == user.id)) {
      selectedMembers.add(user);
    }
  }

  void removeMember(ProfileModel user) {
    selectedMembers.removeWhere((m) => m.id == user.id);
  }

  void addSubtask() {
    if (newSubtaskController.text.trim().isEmpty) return;
    subtasks.add(newSubtaskController.text.trim());
    newSubtaskController.clear();
  }

  void removeSubtask(int index) {
    subtasks.removeAt(index);
  }

  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) {
      selectedDate.value = date;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
    );
    if (time != null) {
      selectedTime.value = time;
    }
  }

  DateTime? get combinedDateTime {
    if (selectedDate.value == null) return null;
    final date = selectedDate.value!;
    final time = selectedTime.value ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> createTask() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a task title');
      return;
    }

    try {
      isLoading.value = true;

      // Create the task
      final task = await _taskService.createTask(
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        dueDate: combinedDateTime,
        memberIds: selectedMembers.map((m) => m.id).toList(),
      );

      if (task != null) {
        // Create subtasks if any
        if (subtasks.isNotEmpty) {
          for (var subtaskTitle in subtasks) {
            try {
              await _client.from('subtasks').insert({
                'task_id': task.id,
                'title': subtaskTitle,
              });
            } catch (e) {
              log('Error creating subtask: $e');
            }
          }
        }

        // Clear form
        titleController.clear();
        descriptionController.clear();
        selectedMembers.clear();
        subtasks.clear();
        selectedDate.value = null;
        selectedTime.value = null;

        // Navigate to dashboard and refresh
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().goToDashboardAndRefresh();
        }
        Get.snackbar('Success', 'Task created successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create task: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

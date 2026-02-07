import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/subtask_model.dart';
import '../../../services/realtime_service.dart';
import '../../../routes/app_pages.dart';

class TaskDetailsController extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;
  final RealtimeService _realtimeService = Get.find<RealtimeService>();

  final Rx<TaskModel?> task = Rx<TaskModel?>(null);
  final RxList<SubtaskModel> subtasks = <SubtaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final newSubtaskController = TextEditingController();

  String? taskId;

  @override
  void onInit() {
    super.onInit();
    taskId = Get.arguments?['taskId'];
    if (taskId != null) {
      loadTaskDetails();
      loadSubtasks();
      _subscribeToTaskUpdates();
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    newSubtaskController.dispose();
    super.onClose();
  }

  void _subscribeToTaskUpdates() {
    _realtimeService.subscribeToTaskUpdates((taskData) {
      if (taskData['id'] == taskId) {
        loadTaskDetails();
      }
    });
  }

  Future<void> loadTaskDetails() async {
    try {
      isLoading.value = true;
      final response = await _client
          .from('tasks')
          .select('*, task_members(profiles(*))')
          .eq('id', taskId!)
          .single();

      task.value = TaskModel.fromJson(response);
      titleController.text = task.value!.title;
      descriptionController.text = task.value!.description ?? '';
    } catch (e) {
      log('Error loading task details: $e');
      Get.snackbar('Error', 'Failed to load task details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubtasks() async {
    try {
      final response = await _client
          .from('subtasks')
          .select()
          .eq('task_id', taskId!)
          .order('created_at', ascending: true);

      subtasks.value = (response as List)
          .map((json) => SubtaskModel.fromJson(json))
          .toList();

      _updateTaskProgress();
    } catch (e) {
      log('Error loading subtasks: $e');
    }
  }

  Future<void> toggleEdit() async {
    if (isEditing.value) {
      // Save changes
      await updateTask();
    }
    isEditing.value = !isEditing.value;
  }

  Future<void> updateTask() async {
    try {
      await _client
          .from('tasks')
          .update({
            'title': titleController.text,
            'description': descriptionController.text,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId!);

      // Update reactive values directly without full reload
      if (task.value != null) {
        task.value = TaskModel(
          id: task.value!.id,
          userId: task.value!.userId,
          title: titleController.text,
          description: descriptionController.text,
          status: task.value!.status,
          dueDate: task.value!.dueDate,
          progress: task.value!.progress,
          createdAt: task.value!.createdAt,
          updatedAt: DateTime.now(),
          members: task.value!.members,
        );
      }

      Get.snackbar('Success', 'Task updated successfully');
    } catch (e) {
      log('Error updating task: $e');
      Get.snackbar('Error', 'Failed to update task');
    }
  }

  Future<void> updateTaskStatus(String status) async {
    try {
      await _client
          .from('tasks')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId!);

      // Update reactive value directly
      if (task.value != null) {
        task.value = TaskModel(
          id: task.value!.id,
          userId: task.value!.userId,
          title: task.value!.title,
          description: task.value!.description,
          status: status,
          dueDate: task.value!.dueDate,
          progress: task.value!.progress,
          createdAt: task.value!.createdAt,
          updatedAt: DateTime.now(),
          members: task.value!.members,
        );
      }
    } catch (e) {
      log('Error updating task status: $e');
      Get.snackbar('Error', 'Failed to update task status');
    }
  }

  Future<void> addSubtask() async {
    if (newSubtaskController.text.trim().isEmpty) return;

    try {
      await _client.from('subtasks').insert({
        'task_id': taskId,
        'title': newSubtaskController.text.trim(),
      });

      newSubtaskController.clear();
      await loadSubtasks();
    } catch (e) {
      log('Error adding subtask: $e');
      Get.snackbar('Error', 'Failed to add subtask');
    }
  }

  Future<void> toggleSubtask(SubtaskModel subtask) async {
    try {
      // Optimistically update UI
      final index = subtasks.indexWhere((s) => s.id == subtask.id);
      if (index != -1) {
        subtasks[index] = subtask.copyWith(isCompleted: !subtask.isCompleted);
      }

      // Update database
      await _client
          .from('subtasks')
          .update({'is_completed': !subtask.isCompleted})
          .eq('id', subtask.id);

      // Update progress
      await _updateTaskProgress();
    } catch (e) {
      log('Error toggling subtask: $e');
      Get.snackbar('Error', 'Failed to update subtask');
      // Revert on error
      await loadSubtasks();
    }
  }

  Future<void> deleteSubtask(String subtaskId) async {
    try {
      // Optimistically update UI
      subtasks.removeWhere((s) => s.id == subtaskId);

      // Delete from database
      await _client.from('subtasks').delete().eq('id', subtaskId);

      // Update progress
      await _updateTaskProgress();
    } catch (e) {
      log('Error deleting subtask: $e');
      Get.snackbar('Error', 'Failed to delete subtask');
      // Reload on error
      await loadSubtasks();
    }
  }

  Future<void> _updateTaskProgress() async {
    if (subtasks.isEmpty) return;

    final completedCount = subtasks.where((s) => s.isCompleted).length;
    final progress = ((completedCount / subtasks.length) * 100).round();

    try {
      await _client
          .from('tasks')
          .update({
            'progress': progress,
            'status': progress == 100 ? 'completed' : 'in_progress',
          })
          .eq('id', taskId!);

      // Update reactive value directly
      if (task.value != null) {
        task.value = TaskModel(
          id: task.value!.id,
          userId: task.value!.userId,
          title: task.value!.title,
          description: task.value!.description,
          status: progress == 100 ? 'completed' : 'in_progress',
          dueDate: task.value!.dueDate,
          progress: progress,
          createdAt: task.value!.createdAt,
          updatedAt: DateTime.now(),
          members: task.value!.members,
        );
      }
    } catch (e) {
      log('Error updating progress: $e');
    }
  }

  void openChat() {
    Get.toNamed(
      Routes.CHAT,
      arguments: {'taskId': taskId, 'taskTitle': task.value?.title},
    );
  }

  Future<void> deleteTask() async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: const Color(0xFF2C3E50),
          title: const Text(
            'Delete Task',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this task? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      await _client.from('tasks').delete().eq('id', taskId!);
      Get.back(); // Return to previous screen
      Get.snackbar('Success', 'Task deleted successfully');
    } catch (e) {
      log('Error deleting task: $e');
      Get.snackbar('Error', 'Failed to delete task');
    }
  }

  Future<void> updateDueDate() async {
    final selectedDate = await showDatePicker(
      context: Get.context!,
      initialDate: task.value?.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107),
              surface: Color(0xFF2C3E50),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    final selectedTime = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.fromDateTime(
        task.value?.dueDate ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFC107),
              surface: Color(0xFF2C3E50),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime == null) return;

    final newDueDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    try {
      await _client
          .from('tasks')
          .update({'due_date': newDueDate.toIso8601String()})
          .eq('id', taskId!);

      if (task.value != null) {
        task.value = TaskModel(
          id: task.value!.id,
          userId: task.value!.userId,
          title: task.value!.title,
          description: task.value!.description,
          status: task.value!.status,
          dueDate: newDueDate,
          progress: task.value!.progress,
          createdAt: task.value!.createdAt,
          updatedAt: DateTime.now(),
          members: task.value!.members,
        );
      }

      Get.snackbar('Success', 'Due date updated successfully');
    } catch (e) {
      log('Error updating due date: $e');
      Get.snackbar('Error', 'Failed to update due date');
    }
  }

  Future<void> showAddMembersDialog() async {
    try {
      // Load all users
      final response = await _client
          .from('profiles')
          .select()
          .order('full_name', ascending: true);

      final allUsers = (response as List)
          .map((json) => ProfileModel.fromJson(json))
          .toList();

      // Filter out existing members
      final existingMemberIds =
          task.value?.members.map((m) => m.id).toSet() ?? {};
      final availableUsers = allUsers
          .where((u) => !existingMemberIds.contains(u.id))
          .toList();

      if (availableUsers.isEmpty) {
        Get.snackbar('Info', 'All users are already members');
        return;
      }

      // Show selection dialog
      final selectedUsers = await Get.dialog<List<ProfileModel>>(
        _buildMemberSelectionDialog(availableUsers),
      );

      if (selectedUsers == null || selectedUsers.isEmpty) return;

      // Add members to task
      for (var user in selectedUsers) {
        await _client.from('task_members').insert({
          'task_id': taskId,
          'user_id': user.id,
        });
      }

      // Reload task details
      await loadTaskDetails();
      Get.snackbar('Success', '${selectedUsers.length} member(s) added');
    } catch (e) {
      log('Error adding members: $e');
      Get.snackbar('Error', 'Failed to add members');
    }
  }

  Widget _buildMemberSelectionDialog(List<ProfileModel> users) {
    final selectedUsers = <ProfileModel>[].obs;

    return AlertDialog(
      backgroundColor: const Color(0xFF2C3E50),
      title: const Text('Add Members', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Obx(
          () => ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelected = selectedUsers.contains(user);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  if (value == true) {
                    selectedUsers.add(user);
                  } else {
                    selectedUsers.remove(user);
                  }
                },
                title: Text(
                  user.displayName,
                  style: const TextStyle(color: Colors.white),
                ),
                secondary: CircleAvatar(
                  backgroundColor: const Color(0xFFFFC107),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.initials,
                          style: const TextStyle(color: Colors.black),
                        )
                      : null,
                ),
                activeColor: const Color(0xFFFFC107),
                checkColor: Colors.black,
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Get.back(result: selectedUsers.toList()),
          child: const Text('Add'),
        ),
      ],
    );
  }

  int get completedSubtasks => subtasks.where((s) => s.isCompleted).length;
  int get totalSubtasks => subtasks.length;
}

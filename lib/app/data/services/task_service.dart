import 'dart:developer';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:day_task/app/data/models/task_model.dart';
import 'package:day_task/app/services/supabase_service.dart';

class TaskService extends GetxService {
  SupabaseClient get _client => Get.find<SupabaseService>().client;
  String? get _userId => Get.find<SupabaseService>().currentUser?.id;

  /// Handle database errors - redirect to signin if auth-related
  void _handleError(dynamic error, String operation) {
    log('TaskService.$operation error: $error');
    final errorStr = error.toString().toLowerCase();

    // Check if it's a network error
    final isNetworkError =
        errorStr.contains('socket') ||
        errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout');

    if (!isNetworkError) {
      // Auth/DB error - redirect to get started (only if not already there)
      if (Get.currentRoute != '/signin' && Get.currentRoute != '/signup') {
        Get.find<SupabaseService>().signOut();
        Get.offAllNamed('/signin');
      }
    }
  }

  /// Fetch all tasks (owned + member of)
  Future<List<TaskModel>> fetchTasks({String? status}) async {
    try {
      var query = _client.from('tasks').select('*, task_members(profiles(*))');

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);
      return (response as List).map((e) => TaskModel.fromJson(e)).toList();
    } catch (e) {
      _handleError(e, 'fetchTasks');
      return [];
    }
  }

  /// Fetch completed tasks
  Future<List<TaskModel>> fetchCompletedTasks() async {
    try {
      final response = await _client
          .from('tasks')
          .select('*, task_members(profiles(*))')
          .eq('status', 'completed')
          .order('updated_at', ascending: false);
      return (response as List).map((e) => TaskModel.fromJson(e)).toList();
    } catch (e) {
      _handleError(e, 'fetchCompletedTasks');
      return [];
    }
  }

  /// Fetch ongoing tasks
  Future<List<TaskModel>> fetchOngoingTasks() async {
    try {
      final response = await _client
          .from('tasks')
          .select('*, task_members(profiles(*))')
          .neq('status', 'completed')
          .order('due_date', ascending: true);
      return (response as List).map((e) => TaskModel.fromJson(e)).toList();
    } catch (e) {
      _handleError(e, 'fetchOngoingTasks');
      return [];
    }
  }

  /// Create a new task
  Future<TaskModel?> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    List<String> memberIds = const [],
  }) async {
    if (_userId == null) return null;

    final taskData = {
      'user_id': _userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'status': 'pending',
      'progress': 0,
    };

    final response = await _client
        .from('tasks')
        .insert(taskData)
        .select('*, task_members(profiles(*))')
        .single();

    final task = TaskModel.fromJson(response);

    // Add team members
    if (memberIds.isNotEmpty) {
      await addMembersToTask(task.id, memberIds);
    }

    return task;
  }

  /// Add members to a task
  Future<void> addMembersToTask(String taskId, List<String> userIds) async {
    final membersData = userIds
        .map(
          (userId) => {'task_id': taskId, 'user_id': userId, 'role': 'editor'},
        )
        .toList();

    await _client.from('task_members').upsert(membersData);
  }

  /// Remove a member from a task
  Future<void> removeMemberFromTask(String taskId, String userId) async {
    await _client
        .from('task_members')
        .delete()
        .eq('task_id', taskId)
        .eq('user_id', userId);
  }

  /// Get task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    final response = await _client
        .from('tasks')
        .select('*, task_members(profiles(*))')
        .eq('id', taskId)
        .single();
    return TaskModel.fromJson(response);
  }

  /// Update task
  Future<TaskModel?> updateTask(
    String taskId,
    Map<String, dynamic> data,
  ) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final response = await _client
        .from('tasks')
        .update(data)
        .eq('id', taskId)
        .select('*, task_members(profiles(*))')
        .single();
    return TaskModel.fromJson(response);
  }

  /// Delete task
  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }

  /// Search all users for team member selection
  Future<List<ProfileModel>> searchUsers(String query) async {
    final response = await _client
        .from('profiles')
        .select()
        .ilike('full_name', '%$query%')
        .neq('id', _userId ?? '')
        .limit(20);
    return (response as List).map((e) => ProfileModel.fromJson(e)).toList();
  }

  /// Get all users (for initial list)
  Future<List<ProfileModel>> getAllUsers() async {
    final response = await _client
        .from('profiles')
        .select()
        .neq('id', _userId ?? '')
        .limit(50);
    return (response as List).map((e) => ProfileModel.fromJson(e)).toList();
  }
}

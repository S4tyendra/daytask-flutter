import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/task_model.dart';
import '../../../services/supabase_service.dart';

import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final _box = GetStorage();

  final Rx<ProfileModel?> profile = Rx<ProfileModel?>(null);
  final RxList<TaskModel> myTasks = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read('isDarkMode') ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTheme();
    });
    loadProfile();
    loadMyTasks();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write('isDarkMode', isDarkMode.value);
    _updateTheme();
  }

  void _updateTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      profile.value = ProfileModel.fromJson(response);
    } catch (e) {
      log('Error loading profile: $e');
      Get.snackbar('Error', 'Failed to load profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMyTasks() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _client
          .from('tasks')
          .select('*, task_members(profiles(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      myTasks.value = (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error loading tasks: $e');
    }
  }

  String get userEmail => _client.auth.currentUser?.email ?? '';

  int get totalTasks => myTasks.length;
  int get completedTasks => myTasks.where((t) => t.isCompleted).length;
  int get pendingTasks => myTasks.where((t) => !t.isCompleted).length;

  Future<void> logout() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: const Color(0xFF34495E),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Color(0xFFFFC107)),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _supabaseService.signOut();
      }
    } catch (e) {
      log('Error logging out: $e');
      Get.snackbar('Error', 'Failed to logout');
    }
  }
}

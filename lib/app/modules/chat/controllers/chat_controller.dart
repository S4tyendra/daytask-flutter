import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/message_model.dart';

class ChatController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final SupabaseClient _client = Supabase.instance.client;

  late TabController tabController;
  final RxInt currentTab = 0.obs;

  // Direct Messages
  final RxList<ProfileModel> directMessageUsers = <ProfileModel>[].obs;
  final RxList<ProfileModel> allUsers = <ProfileModel>[].obs;
  final RxBool isLoadingUsers = false.obs;

  // Groups (Tasks)
  final RxList<TaskModel> taskGroups = <TaskModel>[].obs;
  final RxBool isLoadingGroups = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTab.value = tabController.index;
    });
    loadDirectMessageUsers();
    loadTaskGroups();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadDirectMessageUsers() async {
    try {
      isLoadingUsers.value = true;
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      // Get users who have sent or received messages from current user
      final response = await _client
          .from('messages')
          .select('sender_id, profiles!messages_sender_id_fkey(*)')
          .or('sender_id.neq.$userId')
          .limit(50);

      final users = <ProfileModel>[];
      final seenIds = <String>{};

      for (var msg in response as List) {
        final senderId = msg['sender_id'];
        if (senderId != userId && !seenIds.contains(senderId)) {
          seenIds.add(senderId);
          if (msg['profiles'] != null) {
            users.add(ProfileModel.fromJson(msg['profiles']));
          }
        }
      }

      directMessageUsers.value = users;
    } catch (e) {
      log('Error loading direct message users: $e');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> loadAllUsers() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _client
          .from('profiles')
          .select()
          .neq('id', userId)
          .order('full_name', ascending: true);

      allUsers.value = (response as List)
          .map((json) => ProfileModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error loading all users: $e');
      Get.snackbar('Error', 'Failed to load users');
    }
  }

  Future<void> loadTaskGroups() async {
    try {
      isLoadingGroups.value = true;
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _client
          .from('tasks')
          .select('*, task_members!inner(profiles(*))')
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      taskGroups.value = (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error loading task groups: $e');
      Get.snackbar('Error', 'Failed to load groups');
    } finally {
      isLoadingGroups.value = false;
    }
  }

  void openDirectMessage(ProfileModel user) {
    Get.toNamed(
      '/direct-chat',
      arguments: {
        'userId': user.id,
        'userName': user.displayName,
        'avatarUrl': user.avatarUrl,
      },
    );
  }

  void openTaskChat(TaskModel task) {
    Get.toNamed(
      '/chat',
      arguments: {'taskId': task.id, 'taskTitle': task.title},
    );
  }

  void showAddDirectMessageDialog() async {
    await loadAllUsers();
    Get.bottomSheet(
      _buildUserSelectionSheet(),
      backgroundColor: const Color(0xFF2C3E50),
      isScrollControlled: true,
    );
  }

  Widget _buildUserSelectionSheet() {
    return Container(
      height: Get.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Start a conversation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (allUsers.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                itemCount: allUsers.length,
                itemBuilder: (context, index) {
                  final user = allUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
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
                    title: Text(
                      user.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Get.back();
                      openDirectMessage(user);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

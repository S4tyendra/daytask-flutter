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
  final RxList<ProfileModel> filteredUsers = <ProfileModel>[].obs;
  final RxBool isLoadingUsers = false.obs;
  final RxString searchQuery = ''.obs;

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

    // Listen to search query changes
    debounce(
      searchQuery,
      (_) => filterUsers(),
      time: const Duration(milliseconds: 300),
    );
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

      // Initialize filtered users
      filteredUsers.value = allUsers;
    } catch (e) {
      log('Error loading all users: $e');
      Get.snackbar('Error', 'Failed to load users');
    }
  }

  void filterUsers() {
    if (searchQuery.value.isEmpty) {
      filteredUsers.value = allUsers;
    } else {
      filteredUsers.value = allUsers
          .where(
            (user) => user.displayName.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
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
      '/messages',
      arguments: {'taskId': task.id, 'taskTitle': task.title},
    );
  }

  void showAddDirectMessageDialog() async {
    isLoadingUsers.value = true;
    searchQuery.value = ''; // Reset search
    await loadAllUsers();
    isLoadingUsers.value = false;
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
          const SizedBox(height: 16),

          // Search bar
          TextField(
            onChanged: (value) => searchQuery.value = value,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107)),
              filled: true,
              fillColor: const Color(0xFF34495E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Obx(() {
              if (isLoadingUsers.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFC107)),
                );
              }

              if (filteredUsers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_search,
                        size: 64,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.value.isEmpty
                            ? 'No users found'
                            : 'No users match "${searchQuery.value}"',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: const Color(0xFFFFC107),
          labelColor: const Color(0xFFFFC107),
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Direct'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [_buildDirectMessagesTab(), _buildGroupsTab()],
      ),
      floatingActionButton: Obx(() {
        if (controller.currentTab.value == 0) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFFFFC107),
            onPressed: () {
              controller.showAddDirectMessageDialog();
              // _showUserSelectionSheet();
            },
            child: const Icon(Icons.add, color: Colors.black),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  void _showUserSelectionSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF2C3E50),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
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
              child: GetBuilder<ChatController>(
                builder: (controller) {
                  if (controller.allUsers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.allUsers.length,
                    itemBuilder: (context, index) {
                      final user = controller.allUsers[index];
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
                          controller.openDirectMessage(user);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildDirectMessagesTab() {
    return Obx(() {
      if (controller.isLoadingUsers.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
        );
      }

      if (controller.directMessageUsers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No conversations yet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to start a conversation',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.directMessageUsers.length,
        itemBuilder: (context, index) {
          final user = controller.directMessageUsers[index];
          return _buildDirectMessageCard(user);
        },
      );
    });
  }

  Widget _buildDirectMessageCard(user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(0),
        child: InkWell(
          onTap: () => controller.openDirectMessage(user),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFFFC107),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.initials,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to chat',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFFFC107)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Obx(() {
      if (controller.isLoadingGroups.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
        );
      }

      if (controller.taskGroups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_outlined,
                size: 80,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No group chats yet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a task to start a group chat',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.taskGroups.length,
        itemBuilder: (context, index) {
          final task = controller.taskGroups[index];
          return _buildGroupCard(task);
        },
      );
    });
  }

  Widget _buildGroupCard(task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(0),
        child: InkWell(
          onTap: () => controller.openTaskChat(task),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: const Icon(Icons.group, color: Colors.black, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.members.length} members',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: task.status == 'completed'
                                  ? Colors.green.withOpacity(0.2)
                                  : const Color(0xFFFFC107).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.status == 'completed'
                                  ? 'Completed'
                                  : 'Active',
                              style: TextStyle(
                                color: task.status == 'completed'
                                    ? Colors.green
                                    : const Color(0xFFFFC107),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFFFC107)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:day_task/app/data/models/task_model.dart';
import 'package:day_task/app/routes/app_pages.dart';
import '../controllers/task_list_controller.dart';

class TaskListView extends GetView<TaskListController> {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.theme.colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.title,
            style: TextStyle(
              color: Get.theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.tasks.isEmpty) {
          return Center(
            child: Text(
              'No tasks found',
              style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchTasks,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              return _buildTaskCard(controller.tasks[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(Routes.TASK_DETAILS, arguments: {'taskId': task.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Get.theme.colorScheme.surface),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: Get.theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: TextStyle(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildMemberAvatars(task.members),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Due: ${_formatDate(task.dueDate!)}',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: task.progress / 100,
                    strokeWidth: 3,
                    backgroundColor: Get.theme.colorScheme.primary.withOpacity(
                      0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation(
                      Get.theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${task.progress}%',
                    style: TextStyle(
                      color: Get.theme.colorScheme.onSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatars(List<ProfileModel> members) {
    final displayMembers = members.take(4).toList();
    if (displayMembers.isEmpty) {
      return Text(
        'No team members',
        style: TextStyle(
          color: Get.theme.colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      );
    }
    return SizedBox(
      height: 24,
      child: Stack(
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              left: i * 16.0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Get.theme.colorScheme.primary,
                backgroundImage: displayMembers[i].avatarUrl != null
                    ? NetworkImage(displayMembers[i].avatarUrl!)
                    : null,
                child: displayMembers[i].avatarUrl == null
                    ? Text(
                        displayMembers[i].initials,
                        style: TextStyle(
                          fontSize: 8,
                          color: Get.theme.colorScheme.onPrimary,
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

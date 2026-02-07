import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:day_task/app/data/models/task_model.dart';
import 'package:day_task/app/routes/app_pages.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshTasks,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildCompletedTasksSection()),
              SliverToBoxAdapter(child: _buildOngoingTasksSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final profile = controller.currentUserProfile;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Get.theme.colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.displayName ?? 'User',
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.PROFILE),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Get.theme.colorScheme.primary,
              backgroundImage: profile?.avatarUrl != null
                  ? NetworkImage(profile!.avatarUrl!)
                  : null,
              child: profile?.avatarUrl == null
                  ? Text(
                      profile?.initials ?? '?',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: Icon(
                  Icons.search,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(color: Get.theme.colorScheme.primary),
            child: Icon(Icons.tune, color: Get.theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed Tasks',
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(
                  Routes.TASK_LIST,
                  arguments: {'status': 'completed'},
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: Get.theme.colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.completedTasks.isEmpty) {
              return Center(
                child: Text(
                  'No completed tasks',
                  style: TextStyle(
                    color: Get.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.completedTasks.length,
              itemBuilder: (context, index) {
                return _buildCompletedTaskCard(
                  controller.completedTasks[index],
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCompletedTaskCard(TaskModel task) {
    final colors = [
      Get.theme.colorScheme.primary,
      Get.theme.colorScheme.surface,
    ];
    final color =
        colors[controller.completedTasks.indexOf(task) % colors.length];
    final isYellow = color == Get.theme.colorScheme.primary;

    return GestureDetector(
      onTap: () async {
        await Get.toNamed(Routes.TASK_DETAILS, arguments: {'taskId': task.id});
        // Refresh dashboard when returning
        controller.refreshTasks();
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  color: isYellow
                      ? Get.theme.colorScheme.onPrimary
                      : Get.theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Team members',
              style: TextStyle(
                color: isYellow
                    ? Get.theme.colorScheme.onPrimary.withOpacity(0.7)
                    : Get.theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _buildMemberAvatars(task.members, isYellow),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Completed',
                  style: TextStyle(
                    color: isYellow
                        ? Get.theme.colorScheme.onPrimary
                        : Get.theme.colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${task.progress}%',
                  style: TextStyle(
                    color: isYellow
                        ? Get.theme.colorScheme.onPrimary
                        : Get.theme.colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: task.progress / 100,
              backgroundColor: isYellow
                  ? Get.theme.colorScheme.onPrimary.withOpacity(0.3)
                  : Get.theme.colorScheme.primary.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                isYellow
                    ? Get.theme.colorScheme.onPrimary
                    : Get.theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingTasksSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ongoing Projects',
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(
                  Routes.TASK_LIST,
                  arguments: {'status': 'ongoing'},
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: Get.theme.colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.ongoingTasks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No ongoing tasks',
                style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.ongoingTasks.length,
            itemBuilder: (context, index) {
              return _buildOngoingTaskCard(controller.ongoingTasks[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildOngoingTaskCard(TaskModel task) {
    return GestureDetector(
      onTap: () async {
        await Get.toNamed(Routes.TASK_DETAILS, arguments: {'taskId': task.id});
        // Refresh dashboard when returning
        controller.refreshTasks();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(0),
        ),
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
                  const SizedBox(height: 4),
                  Text(
                    'Team members',
                    style: TextStyle(
                      color: Get.theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMemberAvatars(task.members, false),
                  const SizedBox(height: 12),
                  if (task.dueDate != null)
                    Text(
                      'Due on : ${_formatDate(task.dueDate!)}',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: task.progress / 100,
                    strokeWidth: 4,
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
                      fontSize: 12,
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

  Widget _buildMemberAvatars(List<ProfileModel> members, bool isYellow) {
    final displayMembers = members.take(4).toList();
    return SizedBox(
      height: 28,
      child: Stack(
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              left: i * 18.0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: isYellow
                    ? Get.theme.colorScheme.onPrimary
                    : Get.theme.colorScheme.primary,
                backgroundImage: displayMembers[i].avatarUrl != null
                    ? NetworkImage(displayMembers[i].avatarUrl!)
                    : null,
                child: displayMembers[i].avatarUrl == null
                    ? Text(
                        displayMembers[i].initials,
                        style: TextStyle(
                          fontSize: 10,
                          color: isYellow
                              ? Get.theme.colorScheme.primary
                              : Get.theme.colorScheme.onPrimary,
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
    return '${date.day} ${months[date.month - 1]}';
  }
}

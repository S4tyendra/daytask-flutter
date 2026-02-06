import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:day_task/app/data/models/task_model.dart';
import '../controllers/new_task_controller.dart';

class NewTaskView extends GetView<NewTaskController> {
  const NewTaskView({super.key});

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
        title: Text(
          'Create New Task',
          style: TextStyle(
            color: Get.theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Task Title'),
            const SizedBox(height: 12),
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(hintText: 'Enter task title'),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Task Details'),
            const SizedBox(height: 12),
            TextField(
              controller: controller.descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter task description...',
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Add team members'),
            const SizedBox(height: 12),
            _buildTeamMembersSection(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Time & Date'),
            const SizedBox(height: 12),
            _buildDateTimeSection(context),
            const SizedBox(height: 40),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Get.theme.colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTeamMembersSection(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...controller.selectedMembers.map(
            (member) => _buildMemberChip(member),
          ),
          _buildAddMemberButton(context),
        ],
      ),
    );
  }

  Widget _buildMemberChip(ProfileModel member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Get.theme.colorScheme.primary,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Text(
                    member.initials,
                    style: TextStyle(
                      fontSize: 10,
                      color: Get.theme.colorScheme.onPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            member.displayName,
            style: TextStyle(
              color: Get.theme.colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => controller.removeMember(member),
            child: Icon(
              Icons.close,
              size: 18,
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMemberSelectionSheet(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.add, color: Get.theme.colorScheme.onPrimary),
      ),
    );
  }

  void _showMemberSelectionSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Add Team Members',
                style: TextStyle(
                  color: Get.theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => controller.searchQuery.value = v,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isSearchingUsers.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    final isSelected = controller.selectedMembers.any(
                      (m) => m.id == user.id,
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Get.theme.colorScheme.primary,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.initials,
                                style: TextStyle(
                                  color: Get.theme.colorScheme.onPrimary,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        user.displayName,
                        style: TextStyle(
                          color: Get.theme.colorScheme.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Get.theme.colorScheme.primary,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: Get.theme.colorScheme.onSurfaceVariant,
                            ),
                      onTap: () {
                        if (isSelected) {
                          controller.removeMember(user);
                        } else {
                          controller.addMember(user);
                        }
                      },
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => GestureDetector(
              onTap: () => controller.pickTime(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Get.theme.colorScheme.surface),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Get.theme.colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: Get.theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      controller.selectedTime.value != null
                          ? controller.selectedTime.value!.format(context)
                          : 'Select Time',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => GestureDetector(
              onTap: () => controller.pickDate(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Get.theme.colorScheme.surface),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Get.theme.colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Get.theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      controller.selectedDate.value != null
                          ? '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}'
                          : 'Select Date',
                      style: TextStyle(
                        color: Get.theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.createTask,
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ),
    );
  }
}

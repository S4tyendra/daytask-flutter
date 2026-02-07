import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/task_details_controller.dart';

class TaskDetailsView extends GetView<TaskDetailsController> {
  const TaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isEditing.value ? Icons.check : Icons.edit,
                color: const Color(0xFFFFC107),
              ),
              onPressed: controller.toggleEdit,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF34495E),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  controller.deleteTask();
                  break;
                case 'update_date':
                  controller.updateDueDate();
                  break;
                case 'add_members':
                  controller.showAddMembersDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'update_date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Color(0xFFFFC107)),
                    SizedBox(width: 12),
                    Text(
                      'Update Date & Time',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_members',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Color(0xFFFFC107)),
                    SizedBox(width: 12),
                    Text('Add Members', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete Task', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        final task = controller.task.value;
        if (task == null) {
          return const Center(
            child: Text(
              'Task not found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskTitle(),
                const SizedBox(height: 24),
                _buildTaskInfo(task),
                const SizedBox(height: 24),
                _buildProjectDetails(),
                const SizedBox(height: 24),
                _buildProgressSection(),
                const SizedBox(height: 24),
                _buildSubtasksSection(),
                const SizedBox(height: 24),
                _buildAddSubtaskButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFC107),
        onPressed: controller.openChat,
        child: const Icon(Icons.chat, color: Colors.black),
      ),
    );
  }

  Widget _buildTaskTitle() {
    return Obx(() {
      if (controller.isEditing.value) {
        return TextField(
          controller: controller.titleController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            hintText: 'Task Title',
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFC107)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFC107)),
            ),
          ),
        );
      }

      return Text(
        controller.task.value?.title ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
    });
  }

  Widget _buildTaskInfo(task) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_today, color: Colors.black),
                const SizedBox(height: 8),
                const Text(
                  'Due Date',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  task.dueDate != null
                      ? DateFormat('d MMMM').format(task.dueDate!)
                      : 'No date',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              children: [
                const Icon(Icons.people, color: Colors.black),
                const SizedBox(height: 8),
                const Text(
                  'Project Team',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                const SizedBox(height: 8),
                _buildMemberAvatars(task.members),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberAvatars(List members) {
    final displayMembers = members.take(3).toList();
    return SizedBox(
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              left: i * 20.0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black,
                backgroundImage: displayMembers[i].avatarUrl != null
                    ? NetworkImage(displayMembers[i].avatarUrl!)
                    : null,
                child: displayMembers[i].avatarUrl == null
                    ? Text(
                        displayMembers[i].initials,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFFFC107),
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectDetails() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (controller.isEditing.value)
            TextField(
              controller: controller.descriptionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Task Description',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFC107)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFC107)),
                ),
              ),
            )
          else
            Text(
              controller.task.value?.description ?? 'No description available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 15,
                height: 1.5,
              ),
            ),
        ],
      );
    });
  }

  Widget _buildProgressSection() {
    return Obx(() {
      final task = controller.task.value;
      if (task == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Project Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFC107), width: 4),
                ),
                child: Center(
                  child: Text(
                    '${task.progress}%',
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSubtasksSection() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Tasks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (controller.subtasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No subtasks yet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...controller.subtasks.map((subtask) => _buildSubtaskItem(subtask)),
        ],
      );
    });
  }

  Widget _buildSubtaskItem(subtask) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.toggleSubtask(subtask),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: subtask.isCompleted
                    ? const Color(0xFFFFC107)
                    : Colors.transparent,
                border: Border.all(color: const Color(0xFFFFC107), width: 2),
                shape: BoxShape.circle,
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check, color: Colors.black, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              subtask.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          if (controller.isEditing.value)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => controller.deleteSubtask(subtask.id),
            ),
        ],
      ),
    );
  }

  Widget _buildAddSubtaskButton() {
    return Obx(() {
      if (!controller.isEditing.value) return const SizedBox.shrink();

      return Column(
        children: [
          TextField(
            controller: controller.newSubtaskController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Add new subtask',
              hintStyle: const TextStyle(color: Colors.white54),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFFFFC107)),
                onPressed: controller.addSubtask,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFC107)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFC107)),
              ),
            ),
            onSubmitted: (_) => controller.addSubtask(),
          ),
        ],
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:day_task/app/routes/app_pages.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

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
          'Schedule',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Get.toNamed(Routes.NEW_TASK),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthHeader(),
          _buildWeekCalendar(),
          _buildTodayTasksHeader(),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Obx(
        () => Text(
          controller.currentMonthYear,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    return Obx(() {
      final week = controller.currentWeek;
      final selectedDate = controller.selectedDate.value;

      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: week.length,
          itemBuilder: (context, index) {
            final date = week[index];
            final isSelected =
                date.day == selectedDate.day &&
                date.month == selectedDate.month &&
                date.year == selectedDate.year;

            return GestureDetector(
              onTap: () => controller.selectDate(date),
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFC107)
                      : const Color(0xFF34495E),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getWeekdayName(date.weekday),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildTodayTasksHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Text(
        'Today\'s Tasks',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
        );
      }

      final todayTasks = controller.todayTasks;

      if (todayTasks.isEmpty) {
        return Center(
          child: Text(
            'No tasks scheduled for this day',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: todayTasks.length,
        itemBuilder: (context, index) {
          final task = todayTasks[index];
          final isYellow = index == 0;

          return GestureDetector(
            onTap: () => Get.toNamed(
              Routes.TASK_DETAILS,
              arguments: {'taskId': task.id},
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isYellow
                    ? const Color(0xFFFFC107)
                    : const Color(0xFF34495E),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 60,
                    color: isYellow ? Colors.black : const Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            color: isYellow ? Colors.black : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(task.dueDate!),
                          style: TextStyle(
                            color: isYellow
                                ? Colors.black.withOpacity(0.7)
                                : Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task.members.isNotEmpty)
                    _buildMemberAvatars(task.members, isYellow),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMemberAvatars(List members, bool isYellow) {
    final displayMembers = members.take(3).toList();
    return SizedBox(
      width: 80,
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              right: i * 20.0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: isYellow
                    ? Colors.black
                    : const Color(0xFFFFC107),
                backgroundImage: displayMembers[i].avatarUrl != null
                    ? NetworkImage(displayMembers[i].avatarUrl!)
                    : null,
                child: displayMembers[i].avatarUrl == null
                    ? Text(
                        displayMembers[i].initials,
                        style: TextStyle(
                          fontSize: 10,
                          color: isYellow
                              ? const Color(0xFFFFC107)
                              : Colors.black,
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute - ${(time.hour + 2).toString().padLeft(2, '0')}:$minute';
  }
}

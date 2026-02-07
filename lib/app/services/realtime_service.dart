import 'dart:developer';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/message_model.dart';
import '../data/models/notification_model.dart';

class RealtimeService extends GetxService {
  final SupabaseClient _client = Supabase.instance.client;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadNotificationCount = 0.obs;

  RealtimeChannel? _notificationChannel;
  RealtimeChannel? _taskChannel;
  final Map<String, RealtimeChannel> _chatChannels = {};

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  @override
  void onClose() {
    _notificationChannel?.unsubscribe();
    _taskChannel?.unsubscribe();
    for (var channel in _chatChannels.values) {
      channel.unsubscribe();
    }
    super.onClose();
  }

  // Initialize notification listener
  void _initializeNotifications() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    _notificationChannel = _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            log('New notification received: ${payload.newRecord}');
            final notification = NotificationModel.fromJson(payload.newRecord);
            notifications.insert(0, notification);
            unreadNotificationCount.value++;
          },
        )
        .subscribe();

    // Load existing notifications
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      notifications.value = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      unreadNotificationCount.value = notifications
          .where((n) => !n.isRead)
          .length;
    } catch (e) {
      log('Error loading notifications: $e');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadNotificationCount.value--;
      }
    } catch (e) {
      log('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      notifications.value = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      unreadNotificationCount.value = 0;
    } catch (e) {
      log('Error marking all notifications as read: $e');
    }
  }

  // Subscribe to task updates
  void subscribeToTaskUpdates(Function(Map<String, dynamic>) onUpdate) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    _taskChannel = _client
        .channel('tasks:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'tasks',
          callback: (payload) {
            log('Task updated: ${payload.newRecord}');
            onUpdate(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'task_members',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            log('Added to task: ${payload.newRecord}');
            _createNotification(
              type: 'task_assigned',
              title: 'New Task Assignment',
              message: 'You have been added to a task',
              metadata: {'task_id': payload.newRecord['task_id']},
            );
          },
        )
        .subscribe();
  }

  void unsubscribeFromTaskUpdates() {
    _taskChannel?.unsubscribe();
    _taskChannel = null;
  }

  // Subscribe to chat messages for a specific task
  Stream<List<MessageModel>> subscribeToChatMessages(String taskId) {
    final channel = _client
        .channel('messages:$taskId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'task_id',
            value: taskId,
          ),
          callback: (payload) {
            log('Message event: ${payload.eventType}');
          },
        )
        .subscribe();

    _chatChannels[taskId] = channel;

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('task_id', taskId)
        .order('created_at', ascending: true)
        .map(
          (data) => data.map((json) => MessageModel.fromJson(json)).toList(),
        );
  }

  void unsubscribeFromChat(String taskId) {
    _chatChannels[taskId]?.unsubscribe();
    _chatChannels.remove(taskId);
  }

  Future<void> sendMessage(String taskId, String content) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client.from('messages').insert({
        'task_id': taskId,
        'sender_id': userId,
        'content': content,
      });
    } catch (e) {
      log('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> _createNotification({
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'title': title,
        'message': message,
        'metadata': metadata,
      });
    } catch (e) {
      log('Error creating notification: $e');
    }
  }
}

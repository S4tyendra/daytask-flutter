import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/task_model.dart';

class MessagesController extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  final messageController = TextEditingController();
  final scrollController = ScrollController();

  String? taskId;
  String? taskTitle;

  @override
  void onInit() {
    super.onInit();
    taskId = Get.arguments?['taskId'];
    taskTitle = Get.arguments?['taskTitle'];

    if (taskId != null) {
      loadMessages();
      _subscribeToRealtime();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _client.channel('public:messages:$taskId').unsubscribe();
    super.onClose();
  }

  void _subscribeToRealtime() {
    if (taskId == null) return;

    _client
        .channel('public:messages:$taskId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'task_id',
            value: taskId,
          ),
          callback: (payload) {
            final newMessage = MessageModel.fromJson(payload.newRecord);
            // Fetch sender profile since realtime payload doesn't include joined tables
            _fetchSenderAndAddMessage(newMessage);
          },
        )
        .subscribe();
  }

  Future<void> _fetchSenderAndAddMessage(MessageModel message) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', message.senderId)
          .single();

      final sender = ProfileModel.fromJson(response);

      final messageWithSender = MessageModel(
        id: message.id,
        taskId: message.taskId,
        senderId: message.senderId,
        content: message.content,
        createdAt: message.createdAt,
        sender: sender,
      );

      // Avoid duplicates
      if (!messages.any((m) => m.id == message.id)) {
        messages.add(messageWithSender);
        _scrollToBottom();
      }
    } catch (e) {
      log('Error fetching sender for message: $e');
      messages.add(message); // Add without sender if fetch fails
      _scrollToBottom();
    }
  }

  Future<void> loadMessages() async {
    try {
      isLoading.value = true;
      if (taskId == null) return;

      final response = await _client
          .from('messages')
          .select('*, sender:profiles(*)')
          .eq('task_id', taskId!)
          .order('created_at', ascending: true);

      messages.value = (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();

      _scrollToBottom();
    } catch (e) {
      log('Error loading task messages: $e');
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || taskId == null) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final content = messageController.text.trim();
    messageController.clear();

    // Optimistic update
    final optimisticId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = MessageModel(
      id: optimisticId,
      taskId: taskId!,
      senderId: userId,
      content: content,
      createdAt: DateTime.now(),
      sender:
          null, // Will need to handle null sender in UI or fetch current user profile
    );

    try {
      isSending.value = true;
      messages.add(optimisticMessage);
      _scrollToBottom();

      final response = await _client
          .from('messages')
          .insert({'task_id': taskId, 'sender_id': userId, 'content': content})
          .select()
          .single();

      // Update optimistic message
      final index = messages.indexWhere((m) => m.id == optimisticId);
      if (index != -1) {
        // We can just keep the local sender info if we had it, or update fields
        // Since we don't return relations from insert, sender will be null in response
        // Better to just update ID and timestamp
        final serverMessage = MessageModel.fromJson(response);
        messages[index] = MessageModel(
          id: serverMessage.id,
          taskId: serverMessage.taskId,
          senderId: serverMessage.senderId,
          content: serverMessage.content,
          createdAt: serverMessage.createdAt,
          sender: optimisticMessage.sender, // Preserve sender if we had it
        );
      }
    } catch (e) {
      log('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
      messages.removeWhere((m) => m.id == optimisticId);
    } finally {
      isSending.value = false;
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  bool isMyMessage(MessageModel message) {
    return message.senderId == _client.auth.currentUser?.id;
  }
}

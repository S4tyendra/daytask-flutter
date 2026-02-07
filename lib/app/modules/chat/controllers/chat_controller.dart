import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/task_model.dart';
import '../../../services/realtime_service.dart';

class ChatController extends GetxController {
  final RealtimeService _realtimeService = Get.find<RealtimeService>();
  final SupabaseClient _client = Supabase.instance.client;

  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final Rx<TaskModel?> currentTask = Rx<TaskModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  String? taskId;
  String? taskTitle;

  @override
  void onInit() {
    super.onInit();
    taskId = Get.arguments?['taskId'];
    taskTitle = Get.arguments?['taskTitle'];

    if (taskId != null) {
      _loadTaskDetails();
      _subscribeToMessages();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    if (taskId != null) {
      _realtimeService.unsubscribeFromChat(taskId!);
    }
    super.onClose();
  }

  Future<void> _loadTaskDetails() async {
    try {
      isLoading.value = true;
      final response = await _client
          .from('tasks')
          .select('*, task_members(profiles(*))')
          .eq('id', taskId!)
          .single();

      currentTask.value = TaskModel.fromJson(response);
    } catch (e) {
      log('Error loading task details: $e');
      Get.snackbar('Error', 'Failed to load task details');
    } finally {
      isLoading.value = false;
    }
  }

  void _subscribeToMessages() {
    _realtimeService
        .subscribeToChatMessages(taskId!)
        .listen(
          (messageList) {
            messages.value = messageList;
            _scrollToBottom();
          },
          onError: (error) {
            log('Error in message stream: $error');
          },
        );
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || taskId == null) return;

    try {
      isSending.value = true;
      final content = messageController.text.trim();
      messageController.clear();

      await _realtimeService.sendMessage(taskId!, content);
      _scrollToBottom();
    } catch (e) {
      log('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      isSending.value = false;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool isMyMessage(MessageModel message) {
    return message.senderId == _client.auth.currentUser?.id;
  }
}

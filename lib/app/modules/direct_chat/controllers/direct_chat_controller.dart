import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/message_model.dart';

class DirectChatController extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  final messageController = TextEditingController();
  final scrollController = ScrollController();

  String? otherUserId;
  String? otherUserName;
  String? otherUserAvatar;

  @override
  void onInit() {
    super.onInit();
    otherUserId = Get.arguments?['userId'];
    otherUserName = Get.arguments?['userName'];
    otherUserAvatar = Get.arguments?['avatarUrl'];

    if (otherUserId != null) {
      loadMessages();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadMessages() async {
    try {
      isLoading.value = true;
      final userId = _client.auth.currentUser?.id;
      if (userId == null || otherUserId == null) return;

      final response = await _client
          .from('direct_messages')
          .select('*, sender:profiles!direct_messages_sender_id_fkey(*)')
          .or(
            'and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)',
          )
          .order('created_at', ascending: true);

      messages.value = (response as List)
          .map((json) => MessageModel.fromJson(json))
          .toList();

      _scrollToBottom();
    } catch (e) {
      log('Error loading messages: $e');
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || otherUserId == null) return;

    try {
      isSending.value = true;
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final content = messageController.text.trim();
      messageController.clear();

      await _client.from('direct_messages').insert({
        'sender_id': userId,
        'receiver_id': otherUserId,
        'content': content,
      });

      await loadMessages();
      _scrollToBottom();
    } catch (e) {
      log('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
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

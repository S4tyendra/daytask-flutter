import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/direct_message_model.dart';

class DirectChatController extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;

  final RxList<DirectMessageModel> messages = <DirectMessageModel>[].obs;
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
      _subscribeToRealtime();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _client.channel('public:direct_messages').unsubscribe();
    super.onClose();
  }

  void _subscribeToRealtime() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    _client
        .channel('public:direct_messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'direct_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord['sender_id'] == otherUserId) {
              final newMessage = DirectMessageModel.fromJson(payload.newRecord);
              messages.add(newMessage);
              _scrollToBottom();
            }
          },
        )
        .subscribe();
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
          .map((json) => DirectMessageModel.fromJson(json))
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

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final content = messageController.text.trim();
    messageController.clear();

    // Optimistic update
    final optimisticId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = DirectMessageModel(
      id: optimisticId,
      senderId: userId,
      receiverId: otherUserId!,
      content: content,
      createdAt: DateTime.now(),
    );

    try {
      isSending.value = true;
      messages.add(optimisticMessage);
      _scrollToBottom();

      final response = await _client
          .from('direct_messages')
          .insert({
            'sender_id': userId,
            'receiver_id': otherUserId,
            'content': content,
          })
          .select()
          .single();

      // Update the optimistic message with real data
      // Note: response might not have 'sender' relation, so we keep using optimistic info if needed
      // but strictly we should replace it with the server response
      final index = messages.indexWhere((m) => m.id == optimisticId);
      if (index != -1) {
        messages[index] = DirectMessageModel.fromJson(response);
      }
    } catch (e) {
      log('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
      // Remove optimistic message on failure
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

  bool isMyMessage(DirectMessageModel message) {
    return message.senderId == _client.auth.currentUser?.id;
  }
}

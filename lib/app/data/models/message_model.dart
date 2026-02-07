import 'package:day_task/app/data/models/task_model.dart';

class MessageModel {
  final String id;
  final String taskId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final ProfileModel? sender;

  MessageModel({
    required this.id,
    required this.taskId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      taskId: json['task_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      sender: json['sender'] != null
          ? ProfileModel.fromJson(json['sender'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'sender_id': senderId,
    'content': content,
  };
}

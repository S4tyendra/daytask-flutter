import 'package:day_task/app/data/models/task_model.dart';

class DirectMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final ProfileModel? sender;

  DirectMessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.sender,
  });

  factory DirectMessageModel.fromJson(Map<String, dynamic> json) {
    return DirectMessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      sender: json['sender'] != null
          ? ProfileModel.fromJson(json['sender'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'sender_id': senderId,
    'receiver_id': receiverId,
    'content': content,
  };
}

class SubtaskModel {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory SubtaskModel.fromJson(Map<String, dynamic> json) {
    return SubtaskModel(
      id: json['id'],
      taskId: json['task_id'],
      title: json['title'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'title': title,
    'is_completed': isCompleted,
  };

  SubtaskModel copyWith({bool? isCompleted}) {
    return SubtaskModel(
      id: id,
      taskId: taskId,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}

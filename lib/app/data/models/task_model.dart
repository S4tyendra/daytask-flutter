class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String status;
  final DateTime? dueDate;
  final int progress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProfileModel> members;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    this.progress = 0,
    required this.createdAt,
    required this.updatedAt,
    this.members = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    List<ProfileModel> membersList = [];
    if (json['task_members'] != null) {
      membersList = (json['task_members'] as List)
          .map((m) => ProfileModel.fromJson(m['profiles'] ?? m))
          .toList();
    }

    return TaskModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      progress: json['progress'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      members: membersList,
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'title': title,
    'description': description,
    'status': status,
    'due_date': dueDate?.toIso8601String(),
    'progress': progress,
  };

  bool get isCompleted => status == 'completed' || progress == 100;
}

class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? updatedAt;

  ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'avatar_url': avatarUrl,
  };

  String get displayName => fullName ?? 'Unknown User';
  String get initials {
    if (fullName == null || fullName!.isEmpty) return '?';
    final parts = fullName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName![0].toUpperCase();
  }
}

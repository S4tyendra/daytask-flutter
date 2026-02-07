import 'package:flutter_test/flutter_test.dart';
import 'package:day_task/app/data/models/task_model.dart';

void main() {
  group('TaskModel Tests', () {
    test('TaskModel serialization - toJson', () {
      final task = TaskModel(
        id: '123',
        userId: 'user-456',
        title: 'Complete Flutter Assignment',
        description: 'Build a task management app',
        status: 'pending',
        dueDate: DateTime(2026, 2, 10),
        progress: 75,
        createdAt: DateTime(2026, 2, 5),
        updatedAt: DateTime(2026, 2, 7),
      );

      final json = task.toJson();

      expect(json['user_id'], 'user-456');
      expect(json['title'], 'Complete Flutter Assignment');
      expect(json['description'], 'Build a task management app');
      expect(json['status'], 'pending');
      expect(json['progress'], 75);
      expect(json['due_date'], isNotNull);
    });

    test('TaskModel deserialization - fromJson', () {
      final json = {
        'id': '123',
        'user_id': 'user-456',
        'title': 'Complete Flutter Assignment',
        'description': 'Build a task management app',
        'status': 'in_progress',
        'due_date': '2026-02-10T00:00:00.000',
        'progress': 50,
        'created_at': '2026-02-05T10:00:00.000',
        'updated_at': '2026-02-07T15:30:00.000',
        'task_members': [],
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, '123');
      expect(task.userId, 'user-456');
      expect(task.title, 'Complete Flutter Assignment');
      expect(task.description, 'Build a task management app');
      expect(task.status, 'in_progress');
      expect(task.progress, 50);
      expect(task.dueDate, isNotNull);
      expect(task.createdAt, isNotNull);
      expect(task.updatedAt, isNotNull);
      expect(task.members, isEmpty);
    });

    test('TaskModel handles null description', () {
      final json = {
        'id': '123',
        'user_id': 'user-456',
        'title': 'Simple Task',
        'description': null,
        'status': 'pending',
        'due_date': null,
        'progress': 0,
        'created_at': '2026-02-05T10:00:00.000',
        'updated_at': '2026-02-05T10:00:00.000',
      };

      final task = TaskModel.fromJson(json);

      expect(task.description, isNull);
      expect(task.dueDate, isNull);
      expect(task.progress, 0);
    });

    test('TaskModel isCompleted getter - completed status', () {
      final task = TaskModel(
        id: '123',
        userId: 'user-456',
        title: 'Completed Task',
        status: 'completed',
        progress: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isCompleted, true);
    });

    test('TaskModel isCompleted getter - 100% progress', () {
      final task = TaskModel(
        id: '123',
        userId: 'user-456',
        title: 'Almost Done Task',
        status: 'in_progress',
        progress: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isCompleted, true);
    });

    test('TaskModel isCompleted getter - not completed', () {
      final task = TaskModel(
        id: '123',
        userId: 'user-456',
        title: 'Pending Task',
        status: 'pending',
        progress: 50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(task.isCompleted, false);
    });

    test('TaskModel with members deserialization', () {
      final json = {
        'id': '123',
        'user_id': 'user-456',
        'title': 'Team Task',
        'status': 'in_progress',
        'progress': 30,
        'created_at': '2026-02-05T10:00:00.000',
        'updated_at': '2026-02-05T10:00:00.000',
        'task_members': [
          {
            'profiles': {
              'id': 'member-1',
              'full_name': 'John Doe',
              'avatar_url': 'https://example.com/avatar1.jpg',
              'updated_at': '2026-02-05T10:00:00.000',
            },
          },
          {
            'profiles': {
              'id': 'member-2',
              'full_name': 'Jane Smith',
              'avatar_url': null,
              'updated_at': '2026-02-05T10:00:00.000',
            },
          },
        ],
      };

      final task = TaskModel.fromJson(json);

      expect(task.members.length, 2);
      expect(task.members[0].fullName, 'John Doe');
      expect(task.members[1].fullName, 'Jane Smith');
    });
  });

  group('ProfileModel Tests', () {
    test('ProfileModel serialization', () {
      final profile = ProfileModel(
        id: 'user-123',
        fullName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        updatedAt: DateTime(2026, 2, 5),
      );

      final json = profile.toJson();

      expect(json['id'], 'user-123');
      expect(json['full_name'], 'John Doe');
      expect(json['avatar_url'], 'https://example.com/avatar.jpg');
    });

    test('ProfileModel deserialization', () {
      final json = {
        'id': 'user-123',
        'full_name': 'Jane Smith',
        'avatar_url': 'https://example.com/avatar2.jpg',
        'updated_at': '2026-02-05T10:00:00.000',
      };

      final profile = ProfileModel.fromJson(json);

      expect(profile.id, 'user-123');
      expect(profile.fullName, 'Jane Smith');
      expect(profile.avatarUrl, 'https://example.com/avatar2.jpg');
      expect(profile.updatedAt, isNotNull);
    });

    test('ProfileModel displayName getter - with full name', () {
      final profile = ProfileModel(id: 'user-123', fullName: 'John Doe');

      expect(profile.displayName, 'John Doe');
    });

    test('ProfileModel displayName getter - without full name', () {
      final profile = ProfileModel(id: 'user-123', fullName: null);

      expect(profile.displayName, 'Unknown User');
    });

    test('ProfileModel initials - two names', () {
      final profile = ProfileModel(id: 'user-123', fullName: 'John Doe');

      expect(profile.initials, 'JD');
    });

    test('ProfileModel initials - single name', () {
      final profile = ProfileModel(id: 'user-123', fullName: 'Madonna');

      expect(profile.initials, 'M');
    });

    test('ProfileModel initials - no name', () {
      final profile = ProfileModel(id: 'user-123', fullName: null);

      expect(profile.initials, '?');
    });

    test('ProfileModel initials - empty name', () {
      final profile = ProfileModel(id: 'user-123', fullName: '');

      expect(profile.initials, '?');
    });

    test('ProfileModel initials - three names', () {
      final profile = ProfileModel(
        id: 'user-123',
        fullName: 'John Michael Doe',
      );

      expect(profile.initials, 'JM');
    });
  });
}

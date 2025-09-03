import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { incomplete, inProgress, completed }
enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String userId;
  final DateTime? createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.userId,
    this.createdAt,
  });

  // Convert Firestore document to TaskModel
  factory TaskModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      status: _statusFromString(data["status"]),
      priority: _priorityFromString(data["priority"]),
      userId: data["userId"] ?? "",
      createdAt: data["createdAt"] != null
          ? (data["createdAt"] as Timestamp).toDate()
          : null,
    );
  }

  // Convert TaskModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "status": status.name,
      "priority": priority.name,
      "userId": userId,
      "createdAt": createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Helpers
  static TaskStatus _statusFromString(String? status) {
    switch (status) {
      case "inProgress":
        return TaskStatus.inProgress;
      case "completed":
        return TaskStatus.completed;
      default:
        return TaskStatus.incomplete;
    }
  }

  static TaskPriority _priorityFromString(String? priority) {
    switch (priority) {
      case "high":
        return TaskPriority.high;
      case "medium":
        return TaskPriority.medium;
      default:
        return TaskPriority.low;
    }
  }
}

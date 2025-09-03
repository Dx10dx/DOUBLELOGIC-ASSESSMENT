import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/task.dart';


class TaskService {
  static const demoUserId = "demoUser"; // replace with Firebase Auth uid later
  static final CollectionReference tasksRef =
  FirebaseFirestore.instance.collection("tasks");

  // Add a new task
  static Future<void> addTask(TaskModel task) async {
    await tasksRef.add(task.toMap());
  }

  // Update existing task
  static Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    await tasksRef.doc(taskId).update(updates);
  }

  // Delete task
  static Future<void> deleteTask(String taskId) async {
    await tasksRef.doc(taskId).delete();
  }

  // Stream all tasks for a specific user
  static Stream<List<TaskModel>> streamAllForUser(String userId) {
    return tasksRef
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => TaskModel.fromDoc(doc))
        .toList());
  }

  // Stream tasks filtered by status or priority
  static Stream<List<TaskModel>> streamFilteredTasks({
    required String userId,
    String? status,
    String? priority,
  }) {
    Query query = tasksRef.where("userId", isEqualTo: userId);

    if (status != null) query = query.where("status", isEqualTo: status);
    if (priority != null) query = query.where("priority", isEqualTo: priority);

    return query
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => TaskModel.fromDoc(doc)).toList());
  }
}

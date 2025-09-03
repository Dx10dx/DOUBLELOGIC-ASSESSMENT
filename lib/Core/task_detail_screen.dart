import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailScreen extends StatelessWidget {
  final String userId;
  final String status;
  final String taskId;

  const TaskDetailScreen({super.key, required this.userId, required this.status, required this.taskId});

  Future<void> updateStatus(String newStatus) async {
    final oldRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("tasks")
        .doc(status)
        .collection("items")
        .doc(taskId);

    final data = (await oldRef.get()).data();
    if (data == null) return;

    await oldRef.delete();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("tasks")
        .doc(newStatus)
        .collection("items")
        .doc(taskId)
        .set({...data, "status": newStatus});
  }

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("tasks")
        .doc(status)
        .collection("items")
        .doc(taskId);

    return Scaffold(
      appBar: AppBar(title: const Text("Task Detail"), backgroundColor: Colors.white),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data["title"] ?? "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(data["description"] ?? ""),
                const SizedBox(height: 12),
                Text("Status: ${data["status"]}"),
                Text("Priority: ${data["priority"]}"),
                const SizedBox(height: 20),
                const Text("Update Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: ["incomplete", "inProgress", "completed"].map((s) {
                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        onPressed: () => updateStatus(s),
                        child: Text(s, style: const TextStyle(color: Colors.white)));
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

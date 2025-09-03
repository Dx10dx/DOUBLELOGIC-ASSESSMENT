import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatelessWidget {
  final String userId;
  final String statusFilter; // "" = all, or "incomplete", "inProgress", "completed"

  const TaskListScreen({super.key, required this.userId, required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    List<String> statuses = ["incomplete", "inProgress", "completed"];
    return DefaultTabController(
      length: statusFilter.isEmpty ? statuses.length : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(statusFilter.isEmpty ? "All Tasks" : "${statusFilter[0].toUpperCase()}${statusFilter.substring(1)} Tasks"),
          backgroundColor: Colors.white,
          bottom: statusFilter.isEmpty
              ? TabBar(
            tabs: statuses
                .map((s) => Tab(text: "${s[0].toUpperCase()}${s.substring(1)}"))
                .toList(),
            indicatorColor: Colors.white,
          )
              : null,
        ),
        body: statusFilter.isEmpty
            ? TabBarView(
          children: statuses.map((status) => _taskList(status)).toList(),
        )
            : _taskList(statusFilter),
      ),
    );
  }

  Widget _taskList(String status) {
    final query = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("tasks")
        .doc(status)
        .collection("items")
        .orderBy("createdAt", descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No tasks found"));

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(data["title"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Priority: ${data["priority"]}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TaskDetailScreen(
                            userId: userId,
                            status: status,
                            taskId: docs[index].id,
                          )));
                },
              ),
            );
          },
        );
      },
    );
  }
}

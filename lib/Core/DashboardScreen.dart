import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskman/Core/profile.dart';
import 'task_list_screen.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Stream<List<Map<String, dynamic>>> fetchAllTasks() async* {
    final statuses = ["incomplete", "inProgress", "completed"];
    while (true) {
      List<Map<String, dynamic>> allTasks = [];
      for (final status in statuses) {
        final snapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("tasks")
            .doc(status)
            .collection("items")
            .get();
        allTasks.addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          data["id"] = doc.id;
          data["status"] = status;
          return data;
        }));
      }
      yield allTasks;
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void openList(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TaskListScreen(
            userId: user!.uid,
            statusFilter: status,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _homeTab(),
      TaskListScreen(userId: user!.uid, statusFilter: ""), // All Tasks
      ProfileScreen(user: user!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? "Dashboard"
              : _currentIndex == 1
              ? "Tasks"
              : "Profile",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: tabs[_currentIndex],
      floatingActionButton: _currentIndex != 2
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    TaskFormScreen(userId: user!.uid, initialStatus: "incomplete")),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _homeTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: fetchAllTasks(),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final pending = tasks.where((t) => t["status"] == "incomplete").length;
        final inProgress = tasks.where((t) => t["status"] == "inProgress").length;
        final completed = tasks.where((t) => t["status"] == "completed").length;

        final recentTasks = tasks.take(5).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                "Hello, ${user?.displayName ?? 'User'}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Total tasks: ${tasks.length}"),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatusCard(
                      title: "Pending",
                      count: pending,
                      color: Colors.orange,
                      onTap: () => openList("incomplete")),
                  const SizedBox(width: 8),
                  _StatusCard(
                      title: "In Progress",
                      count: inProgress,
                      color: Colors.blue,
                      onTap: () => openList("inProgress")),
                  const SizedBox(width: 8),
                  _StatusCard(
                      title: "Completed",
                      count: completed,
                      color: Colors.green,
                      onTap: () => openList("completed")),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Recent Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...recentTasks.map((t) => Card(
                child: ListTile(
                  title: Text(t["title"] ?? "",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("Status: ${t["status"]} • Priority: ${t["priority"]}"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(
                              userId: user!.uid,
                              status: t["status"],
                              taskId: t["id"],
                            )));
                  },
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _StatusCard(
      {required this.title, required this.count, required this.onTap, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Column(
            children: [
              Text("$count",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 6),
              Text(title, style: TextStyle(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

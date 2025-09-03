import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskFormScreen extends StatefulWidget {
  final String userId;
  final String initialStatus;

  const TaskFormScreen({super.key, required this.userId, required this.initialStatus});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _status = "";
  String _priority = "medium";

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("tasks")
          .doc(_status)
          .collection("items")
          .add({
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "priority": _priority,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Task"), backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Task Title", border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: "Priority", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "high", child: Text("High")),
                  DropdownMenuItem(value: "medium", child: Text("Medium")),
                  DropdownMenuItem(value: "low", child: Text("Low")),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("Save Task"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

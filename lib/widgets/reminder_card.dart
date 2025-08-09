import 'package:flutter/material.dart';

class ReminderCard extends StatelessWidget {
  final String name, dose, time;
  final VoidCallback? onDelete;
  const ReminderCard({super.key, required this.name, required this.dose, required this.time, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal:16, vertical:8),
      child: ListTile(
        leading: const Icon(Icons.medication_outlined, color: Colors.blue),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$dose • $time'),
        trailing: onDelete == null ? null : IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

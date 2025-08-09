import 'package:flutter/material.dart';
import 'package:medi_alert/widgets/gradient_app_bar.dart';
import 'package:medi_alert/widgets/gradient_fab.dart';
import 'package:medi_alert/widgets/reminder_card.dart';
import 'package:medi_alert/data/demo_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        titleText: "Today's Medicine",
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF0F0F0)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: DemoData.remindersStream(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final reminders = snap.data!;
            if (reminders.isEmpty) {
              return const Center(child: Text('No reminders yet'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 96),
              itemCount: reminders.length,
              itemBuilder: (context, i) {
                final r = reminders[i];
                return ReminderCard(
                  name: r['name'],
                  dose: r['dose'],
                  time: r['time'],
                  onDelete: () { setState(() => DemoData.deleteAt(i)); },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: GradientFAB(
        onPressed: () => _openAddDialog(context),
      ),
    );
  }

  void _openAddDialog(BuildContext context) {
    final name = TextEditingController();
    final dose = TextEditingController();
    TimeOfDay? selected;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Medicine Reminder'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dose,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dosage (mg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context, initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => selected = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Select Time',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    selected != null ? selected!.format(context) : 'Tap to pick time',
                  ),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.text.isNotEmpty && dose.text.isNotEmpty && selected != null) {
                  DemoData.addReminder(name.text, dose.text, selected!.format(context));
                  Navigator.pop(context);
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}

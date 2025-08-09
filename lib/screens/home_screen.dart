import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ReminderService reminderService;

  @override
  void initState() {
    super.initState();
    // requestNotificationPermission();
  }

  // Future<void> requestNotificationPermission() async {
  //   if (await Permission.notification.isDenied) {
  //     await Permission.notification.request();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthService>(context);
    // reminderService = ReminderService(userId: auth.userId!);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Medicine", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Logout')),
                  ],
                ),
              );

              // if (shouldLogout == true) {
              //   // context across async gap এ warning এড়াতে আগে navigator নিন
              //   final navigator = Navigator.of(context);
              //   // provider থেকে auth নিয়ে signOut
              //   await context.read<AuthService>().signOut();
              //
              //   // যদি আপনার main.dart এ auth.currentUser null হলে LoginScreen দেখায়,
              //   // তাহলে আলাদা করে navigate দরকার নেই। চাইলে snackbar দেখাতে পারেন:
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text('Logged out')),
              //   );
              //
              //   // (ঐচ্ছিক) যদি আপনি রাউটিং দিয়ে LoginScreen-এ যেতে চান:
              //   // navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              // }
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // child: StreamBuilder<QuerySnapshot>(
        //   stream: reminderService.getReminders(),
        //   builder: (context, snapshot) {
        //     if (snapshot.hasError) {
        //       return const Center(child: Text("Error loading reminders"));
        //     }
        //     if (!snapshot.hasData) {
        //       return const Center(child: CircularProgressIndicator());
        //     }
        //
        //     final reminders = snapshot.data!.docs;
        //
        //     if (reminders.isEmpty) {
        //       return const Center(child: Text("No reminders yet"));
        //     }
        //
        //     return ListView.builder(
        //       padding: const EdgeInsets.only(top: kToolbarHeight + 20),
        //       itemCount: reminders.length,
        //       itemBuilder: (context, index) {
        //         final doc = reminders[index];
        //         final data = doc.data() as Map<String, dynamic>;
        //         return Card(
        //           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //           child: ListTile(
        //             leading: const Icon(Icons.medication_outlined, color: Colors.blue),
        //             title: Text(data['name'] ?? 'No Name'),
        //             subtitle: Text("${data['dose']} - ${data['time']}"),
        //             trailing: IconButton(
        //               icon: const Icon(Icons.delete, color: Colors.redAccent),
        //               onPressed: () => reminderService.deleteReminder(doc.id),
        //             ),
        //           ),
        //         );
        //       },
        //     );
        //   },
        // ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          // ekhane amra ekta static stream use korchi
          stream: Stream.value([
            {
              'name': 'Paracetamol',
              'dose': '500mg',
              'time': '9:00 AM',
            },
            {
              'name': 'Vitamin C',
              'dose': '1000mg',
              'time': '2:00 PM',
            },
            {
              'name': 'Antibiotic',
              'dose': '250mg',
              'time': '8:00 PM',
            },
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reminders = snapshot.data!;

            if (reminders.isEmpty) {
              return const Center(child: Text("No reminders yet"));
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: kToolbarHeight + 20),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final data = reminders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.medication_outlined, color: Colors.blue),
                    title: Text(data['name'] ?? 'No Name'),
                    subtitle: Text("${data['dose']} - ${data['time']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {}, // demo te delete dorkar nei
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final nameController = TextEditingController();
          final doseController = TextEditingController();
          TimeOfDay? selectedTime;

          showDialog(
            context: context,
            builder: (_) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text("Add Medicine Reminder"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Medicine Name",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medication),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: doseController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Dosage (mg)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_hospital),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => selectedTime = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Select Time",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : "Tap to pick time",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (nameController.text.isNotEmpty &&
                          doseController.text.isNotEmpty &&
                          selectedTime != null) {
                        final now = DateTime.now();
                        final scheduledTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );

                        await reminderService.addReminder(
                          nameController.text,
                          doseController.text,
                          selectedTime!.format(context),
                        );

                        await NotificationService.scheduleNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: 'Medicine Reminder',
                          body: '${nameController.text} - ${doseController.text}',
                          scheduledDateTime: scheduledTime,
                        );

                        if (mounted) Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please fill all fields")),
                        );
                      }
                    },
                    child: const Text("Save"),
                  )
                ],
              ),
            ),
          );
        },
        elevation: 6,
        backgroundColor: Colors.transparent,
        child: Ink(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

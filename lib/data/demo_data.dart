class DemoData {
  static final reminders = <Map<String, dynamic>>[
    {'name': 'Paracetamol', 'dose': '500mg', 'time': '9:00 AM', 'created_at': DateTime.now().subtract(const Duration(hours: 2))},
    {'name': 'Vitamin C',   'dose': '1000mg','time': '2:00 PM', 'created_at': DateTime.now().add(const Duration(hours: 2))},
    {'name': 'Antibiotic',  'dose': '250mg', 'time': '8:00 PM', 'created_at': DateTime.now().subtract(const Duration(days: 1, hours: 1))},
  ];

  static Stream<List<Map<String, dynamic>>> remindersStream() async* {
    // purely static once
    yield reminders;
  }

  static void addReminder(String name, String dose, String time) {
    reminders.add({'name': name, 'dose': dose, 'time': time, 'created_at': DateTime.now()});
  }

  static void deleteAt(int index) {
    reminders.removeAt(index);
  }
}

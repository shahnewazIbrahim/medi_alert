import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/reminder_service.dart';

enum HistoryRange { today, week, month }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryRange _range = HistoryRange.today;

  DateTime _rangeStart(HistoryRange r) {
    final now = DateTime.now();
    switch (r) {
      case HistoryRange.today:
        return DateTime(now.year, now.month, now.day);
      case HistoryRange.week:
        return now.subtract(const Duration(days: 7));
      case HistoryRange.month:
        return now.subtract(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final service = ReminderService(userId: auth.userId!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine History', style: TextStyle(color: Colors.white)),
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Today'),
                    selected: _range == HistoryRange.today,
                    onSelected: (_) => setState(() => _range = HistoryRange.today),
                  ),
                  ChoiceChip(
                    label: const Text('Last 7 days'),
                    selected: _range == HistoryRange.week,
                    onSelected: (_) => setState(() => _range = HistoryRange.week),
                  ),
                  ChoiceChip(
                    label: const Text('Last 30 days'),
                    selected: _range == HistoryRange.month,
                    onSelected: (_) => setState(() => _range = HistoryRange.month),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: service.getRemindersSince(_rangeStart(_range)),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Center(child: Text('Failed to load history'));
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final now = DateTime.now();
                  // Map -> scheduled DateTime from created_at + parsed time
                  final items = snap.data!.docs
                      .map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final Timestamp? ts = data['created_at'] as Timestamp?;
                    final created = ts?.toDate();
                    final timeStr = (data['time'] ?? '') as String;

                    if (created == null) return null; // ignore docs without server time yet
                    final hm = _parseTime12h(timeStr); // (hour, minute)
                    if (hm == null) return null;

                    final scheduled = DateTime(
                      created.year,
                      created.month,
                      created.day,
                      hm.$1,
                      hm.$2,
                    );

                    return {
                      'name': data['name'] ?? 'Unknown',
                      'dose': data['dose'] ?? '',
                      'timeStr': timeStr,
                      'scheduled': scheduled,
                    };
                  })
                      .where((m) => m != null)
                      .cast<Map<String, dynamic>>()
                  // keep only past items (scheduled <= now)
                      .where((m) => (m['scheduled'] as DateTime).isBefore(now) ||
                      (m['scheduled'] as DateTime).isAtSameMomentAs(now))
                      .toList();

                  // Sort by scheduled desc (latest first)
                  items.sort((a, b) =>
                      (b['scheduled'] as DateTime).compareTo(a['scheduled'] as DateTime));

                  if (items.isEmpty) {
                    return const Center(child: Text('No history found'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final m = items[i];
                      final name = m['name'] as String;
                      final dose = m['dose'] as String;
                      final timeStr = m['timeStr'] as String;
                      final scheduled = m['scheduled'] as DateTime;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.history, color: Colors.blue),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('$dose • $timeStr • ${_formatDate(scheduled)}'),
                        ),
                      );
                    },
                  );
                },
              ),
              // child: StreamBuilder<List<Map<String, dynamic>>>(
              //   stream: Stream.value([
              //     {
              //       'name': 'Paracetamol',
              //       'dose': '500mg',
              //       'time': '9:00 AM',
              //       'created_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
              //     },
              //     {
              //       'name': 'Vitamin C',
              //       'dose': '1000mg',
              //       'time': '2:00 PM',
              //       'created_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
              //     },
              //     {
              //       'name': 'Antibiotic',
              //       'dose': '250mg',
              //       'time': '8:00 PM',
              //       'created_at': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10))),
              //     },
              //   ]),
              //   builder: (context, snap) {
              //     if (!snap.hasData) {
              //       return const Center(child: CircularProgressIndicator());
              //     }
              //
              //     final now = DateTime.now();
              //     final items = snap.data!
              //         .map((data) {
              //       final Timestamp? ts = data['created_at'] as Timestamp?;
              //       final created = ts?.toDate();
              //       final timeStr = (data['time'] ?? '') as String;
              //
              //       if (created == null) return null;
              //       final hm = _parseTime12h(timeStr);
              //       if (hm == null) return null;
              //
              //       final scheduled = DateTime(
              //         created.year,
              //         created.month,
              //         created.day,
              //         hm.$1,
              //         hm.$2,
              //       );
              //
              //       return {
              //         'name': data['name'] ?? 'Unknown',
              //         'dose': data['dose'] ?? '',
              //         'timeStr': timeStr,
              //         'scheduled': scheduled,
              //       };
              //     })
              //         .where((m) => m != null)
              //         .cast<Map<String, dynamic>>()
              //         .where((m) =>
              //     (m['scheduled'] as DateTime).isBefore(now) ||
              //         (m['scheduled'] as DateTime).isAtSameMomentAs(now))
              //         .toList();
              //
              //     items.sort((a, b) =>
              //         (b['scheduled'] as DateTime).compareTo(a['scheduled'] as DateTime));
              //
              //     if (items.isEmpty) {
              //       return const Center(child: Text('No history found'));
              //     }
              //
              //     return ListView.builder(
              //       padding: const EdgeInsets.only(top: 8, bottom: 16),
              //       itemCount: items.length,
              //       itemBuilder: (context, i) {
              //         final m = items[i];
              //         return Card(
              //           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              //           child: ListTile(
              //             leading: const Icon(Icons.history, color: Colors.blue),
              //             title: Text(m['name'] as String,
              //                 style: const TextStyle(fontWeight: FontWeight.w600)),
              //             subtitle: Text(
              //                 '${m['dose']} • ${m['timeStr']} • ${_formatDate(m['scheduled'] as DateTime)}'),
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),


            ),
          ],
        ),
      ),
    );
  }

  // Parses "9:05 AM" / "9 AM" / "12:30 pm"
  // returns (hour24, minute) or null if invalid
  (int, int)? _parseTime12h(String input) {
    final r = RegExp(r'^\s*(\d{1,2})(?::(\d{2}))?\s*(AM|PM)\s*$',
        caseSensitive: false);
    final m = r.firstMatch(input);
    if (m == null) return null;
    var h = int.tryParse(m.group(1)!);
    var min = int.tryParse(m.group(2) ?? '0') ?? 0;
    final ap = m.group(3)!.toUpperCase();

    if (h == null || h < 1 || h > 12) return null;
    if (min < 0 || min > 59) return null;

    if (ap == 'AM') {
      if (h == 12) h = 0; // 12:xx AM -> 00:xx
    } else {
      if (h != 12) h += 12; // PM add 12 except 12 PM
    }
    return (h, min);
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _formatDate(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';
}

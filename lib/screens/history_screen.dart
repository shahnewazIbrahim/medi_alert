import 'package:flutter/material.dart';
import 'package:medi_alert/widgets/gradient_app_bar.dart';
import 'package:medi_alert/data/demo_data.dart';

enum HistoryRange { today, week, month }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryRange _range = HistoryRange.today;

  DateTime _startFor(HistoryRange r) {
    final now = DateTime.now();
    return switch (r) {
      HistoryRange.today => DateTime(now.year, now.month, now.day),
      HistoryRange.week  => now.subtract(const Duration(days: 7)),
      HistoryRange.month => now.subtract(const Duration(days: 30)),
    };
  }

  (int, int)? _parseTime12h(String input) {
    final r = RegExp(r'^\s*(\d{1,2})(?::(\d{2}))?\s*(AM|PM)\s*$', caseSensitive: false);
    final m = r.firstMatch(input);
    if (m == null) return null;
    var h = int.parse(m.group(1)!);
    final min = int.tryParse(m.group(2) ?? '0') ?? 0;
    final ap = m.group(3)!.toUpperCase();
    if (h < 1 || h > 12 || min < 0 || min > 59) return null;
    if (ap == 'AM') { if (h == 12) h = 0; } else { if (h != 12) h += 12; }
    return (h, min);
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _fmt(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

  @override
  Widget build(BuildContext context) {
    final from = _startFor(_range);
    final now = DateTime.now();

    return Scaffold(
      appBar: GradientAppBar(titleText: 'Medicine History'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.white, Color(0xFFF0F0F0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(label: const Text('Today'), selected: _range==HistoryRange.today, onSelected: (_)=> setState(()=> _range=HistoryRange.today)),
                  ChoiceChip(label: const Text('Last 7 days'), selected: _range==HistoryRange.week, onSelected: (_)=> setState(()=> _range=HistoryRange.week)),
                  ChoiceChip(label: const Text('Last 30 days'), selected: _range==HistoryRange.month, onSelected: (_)=> setState(()=> _range=HistoryRange.month)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: DemoData.remindersStream(),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final list = snap.data!;

                  final items = list.map((e) {
                    final created = (e['created_at'] as DateTime?) ?? DateTime.now();
                    final timeStr = (e['time'] as String?) ?? '';
                    final hm = _parseTime12h(timeStr);
                    if (hm == null) return null;
                    final scheduled = DateTime(created.year, created.month, created.day, hm.$1, hm.$2);
                    return {
                      'name': e['name'] ?? 'Unknown',
                      'dose': e['dose'] ?? '',
                      'time': timeStr,
                      'scheduled': scheduled,
                    };
                  }).where((m) => m != null)
                      .cast<Map<String,dynamic>>()
                      .where((m) => (m['scheduled'] as DateTime).isBefore(now) &&
                      (m['scheduled'] as DateTime).isAfter(from))
                      .toList()
                    ..sort((a,b)=> (b['scheduled'] as DateTime).compareTo(a['scheduled'] as DateTime));

                  if (items.isEmpty) return const Center(child: Text('No history found'));

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final m = items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal:16, vertical:6),
                        child: ListTile(
                          leading: const Icon(Icons.history, color: Colors.blue),
                          title: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${m['dose']} • ${m['time']} • ${_fmt(m['scheduled'])}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

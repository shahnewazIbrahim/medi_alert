import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReminderService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  ReminderService({required this.userId});

  Stream<QuerySnapshot> getReminders() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .orderBy('time')
        .snapshots();
  }

  Future<void> addReminder(String name, String dose, String time) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .add({
      'name': name,
      'dose': dose,
      'time': time, // e.g. "9:05 AM"
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReminder(String docId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(docId)
        .delete();
  }

  // 🔹 History source: same 'reminders' collection, filtered by created_at
  Stream<QuerySnapshot> getRemindersSince(DateTime from) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .orderBy('created_at', descending: true)
        .snapshots();
  }
}

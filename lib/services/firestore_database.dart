import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/services/firestore_path.dart';
import 'package:timeplan/services/firestore_service.dart';
String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

/*
This is the main class access/call for any UI widgets that require to perform
any CRUD activities operation in Firestore database.
This class work hand-in-hand with FirestoreService and FirestorePath.

Notes:
For cases where you need to have a special method such as bulk update specifically
on a field, then is ok to use custom code and write it here. For example,
setAllTodoComplete is require to change all todos item to have the complete status
changed to true.

 */
class FirestoreDatabase {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _firestoreService = FirestoreService.instance;

  //Method to create/update reminderModel
  Future<void> setreminder(Reminder reminder) async => await _firestoreService.setData(
        path: FirestorePath.reminder(uid, reminder.id),
        data: reminder.toMap(),
      );

  //Method to delete reminderModel entry
  Future<void> deleteReminder(Reminder reminder) async {
    await _firestoreService.deleteData(path: FirestorePath.reminder(uid, reminder.id));
  }

  //Method to retrieve reminderModel object based on the given reminderId
  Stream<Reminder> reminderStream({@required String reminderId}) =>
      _firestoreService.documentStream(
        path: FirestorePath.reminder(uid, reminderId),
        builder: (data, documentId) => Reminder.fromMap(data, documentId),
      );

  //Method to retrieve all reminders item from the same user based on uid
  Stream<List<Reminder>> remindersStream() => _firestoreService.collectionStream(
        path: FirestorePath.reminders(uid),
        builder: (data, documentId) => Reminder.fromMap(data, documentId),
      );

  //Method to mark all reminderModel to be complete
  Future<void> setAllreminderComplete() async {
    final batchUpdate = FirebaseFirestore.instance.batch();

    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestorePath.reminders(uid))
        .get();

    for (DocumentSnapshot ds in querySnapshot.docs) {
      batchUpdate.update(ds.reference, {'complete': true});
    }
    await batchUpdate.commit();
  }

  Future<void> deleteAllreminderWithComplete() async {
    final batchDelete = FirebaseFirestore.instance.batch();

    final querySnapshot = await FirebaseFirestore.instance
        .collection(FirestorePath.reminders(uid))
        .where('complete', isEqualTo: true)
        .get();

    for (DocumentSnapshot ds in querySnapshot.docs) {
      batchDelete.delete(ds.reference);
    }
    await batchDelete.commit();
  }
}

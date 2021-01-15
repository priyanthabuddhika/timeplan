import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:timeplan/models/note.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/models/schedule.dart';
import 'package:timeplan/services/firestore_path.dart';
import 'package:timeplan/services/firestore_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _firestoreService = FirestoreService.instance;

  //Method to create/update reminderModel
  Future<void> setreminder(Reminder reminder) async =>
      await _firestoreService.setData(
        path: FirestorePath.reminder(uid, reminder.id),
        data: reminder.toMap(),
      );

  //Method to create/update ScheduleMOdel
  Future<void> setSchedule(Schedule schedule) async =>
      await _firestoreService.setData(
        path: FirestorePath.schedule(uid, schedule.id),
        data: schedule.toMap(),
      );

  //Method to create/update note
  Future<void> setNote(Note note) async => await _firestoreService.setData(
        path: FirestorePath.note(uid, note.id),
        data: note.toMap(),
      );

  //Method to delete reminderModel entry
  Future<void> deleteReminder(Reminder reminder) async {
    await _firestoreService.deleteData(
        path: FirestorePath.reminder(uid, reminder.id));
  }

  //Method to delete schedule entry
  Future<void> deleteSchedule(Schedule schedule) async {
    await _firestoreService.deleteData(
        path: FirestorePath.schedule(uid, schedule.id));
  }

  //Method to delete schedule entry
  Future<void> deleteNote(Note note) async {
    await _firestoreService.deleteData(path: FirestorePath.note(uid, note.id));
  }

  //Method to retrieve reminderModel object based on the given reminderId
  Stream<Reminder> reminderStream({@required String id}) =>
      _firestoreService.documentStream(
        path: FirestorePath.reminder(uid, id),
        builder: (data, id) => Reminder.fromMap(data, id),
      );
  //Method to retrieve schedule object based on the given id
  Stream<Schedule> scheduleStream({@required String id}) =>
      _firestoreService.documentStream(
        path: FirestorePath.schedule(uid, id),
        builder: (data, id) => Schedule.fromMap(data, id),
      );

  //Method to retrieve note object based on the given id
  Stream<Note> noteStream({@required String id}) =>
      _firestoreService.documentStream(
        path: FirestorePath.note(uid, id),
        builder: (data, id) => Note.fromMap(data, id),
      );

  //Method to retrieve all reminders item from the same user based on uid
  Stream<List<Reminder>> remindersStream() =>
      _firestoreService.collectionStream(
        path: FirestorePath.reminders(uid),
        builder: (data, documentId) => Reminder.fromMap(data, documentId),
      );

  //Method to retrieve all reminders item from the same user based on uid
  Stream<List<Schedule>> schedulesStream() =>
      _firestoreService.collectionStream(
        path: FirestorePath.schedules(uid),
        builder: (data, documentId) => Schedule.fromMap(data, documentId),
      );

  //Method to retrieve all notes item from the same user based on uid
  Stream<List<Note>> notesStream() => _firestoreService.collectionStream(
        path: FirestorePath.notes(uid),
        builder: (data, documentId) => Note.fromMap(data, documentId),
      );

  // Method to retrieve schedule list for day
  Stream<List<Schedule>> schedulesForDay({String day}) {
    return _firestoreService.collectionStream(
      queryBuilder: (query) {
        return query.where("date", isEqualTo: day);
      },
      path: FirestorePath.schedules(uid),
      builder: (data, documentId) => Schedule.fromMap(data, documentId),
    );
  }

  // Method to retrieve reminders list for day
  Stream<List<Reminder>> remindersForDay({DateTime day, DateTime datePlus}) {
    print(day.toString());
    String date = day.toString().split(' ')[0];
    String dayPlus = datePlus.toString().split(' ')[0];

    return _firestoreService.collectionStream(
      queryBuilder: (query) {
        return query
            .where("date", isGreaterThanOrEqualTo: date)
            .where("date", isLessThan: dayPlus);
      },
      path: FirestorePath.reminders(uid),
      builder: (data, documentId) => Reminder.fromMap(data, documentId),
    );
  }

  // Method to retrieve next event for day
  Stream<List<Schedule>> nextEvent({DateTime day}) {
    String weekDay = DateFormat('EEEE').format(day);
    // Timestamp date = Timestamp.fromDate(day);
    // Timestamp.fromDate(datePlus);
    return _firestoreService.collectionStream(
      queryBuilder: (query) {
        return query.where("date", isGreaterThanOrEqualTo: weekDay);
      },
      path: FirestorePath.schedules(uid),
      builder: (data, documentId) => Schedule.fromMap(data, documentId),
    );
  }

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

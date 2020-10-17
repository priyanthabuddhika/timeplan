import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timeplan/models/remider.dart';

class DatabaseHelper {
  Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'REMINDER.db'),
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE reminders(id INTEGER PRIMARY KEY, type TEXT, date TEXT, title TEXT, description TEXT)");
        return db;
      },
      version: 1,
    );
  }

  Future<int> insertReminder(Reminder reminder) async {
    int reminderId = 0;
    Database _db = await database();
    await _db
        .insert('reminders', reminder.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) {
      reminderId = value;
    });
    return reminderId;
  }

  Future<void> updateReminderTitle(int id, String title) async {
    Database _db = await database();
    await _db
        .rawUpdate("UPDATE reminders SET title = '$title' WHERE id = '$id'");
  }

  Future<void> updateReminderDescription(int id, String description) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE reminders SET description = '$description' WHERE id = '$id'");
  }

  Future<void> updateReminderType(int id, String type) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE reminders SET type = '$type' WHERE id = '$id'");
  }

  Future<void> updateReminderDate(int id, String date) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE reminders SET date = '$date' WHERE id = '$id'");
  }

  // Future<void> updateReminderTime(int id, String time) async {
  //   Database _db = await database();
  //   await _db.rawUpdate("UPDATE reminders SET time = '$time' WHERE id = '$id'");
  // }

  Future<List<Reminder>> getReminders() async {
    Database _db = await database();
    List<Map<String, dynamic>> reminderMap = await _db.query('reminders');
    return List.generate(reminderMap.length, (index) {
      return Reminder(
        id: reminderMap[index]['id'],
        title: reminderMap[index]['title'],
        description: reminderMap[index]['description'],
        type: reminderMap[index]['type'],
        date: reminderMap[index]['date'],
        // time: reminderMap[index]['time'],
      );
    });
  }

  Future<void> deleteReminder(int id) async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM reminders WHERE id = '$id'");
  }
}

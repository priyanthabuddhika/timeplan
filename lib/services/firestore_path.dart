/*
This class defines all the possible read/write locations from the Firestore database.
In future, any new path can be added here.
This class work together with FirestoreService and FirestoreDatabase.
 */

class FirestorePath {
  static String reminder(String uid, String reminderId) => 'users/$uid/reminders/$reminderId';
  static String reminders(String uid) => 'users/$uid/reminders';
  static String schedule(String uid, String scheduleId) => 'users/$uid/schedules/$scheduleId';
  static String schedules(String uid) => 'users/$uid/schedules';
  static String note(String uid, String noteId) => 'users/$uid/notes/$noteId';
  static String notes(String uid) => 'users/$uid/notes';
}

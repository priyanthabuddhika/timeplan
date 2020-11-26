/*
This class defines all the possible read/write locations from the Firestore database.
In future, any new path can be added here.
This class work together with FirestoreService and FirestoreDatabase.
 */

class FirestorePath {
  static String reminder(String uid, String reminderId) => 'users/$uid/reminders/$reminderId';
  static String reminders(String uid) => 'users/$uid/reminders';
}

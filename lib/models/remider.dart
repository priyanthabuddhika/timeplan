
class Reminder {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  Reminder({
    this.id,
    this.title,
    this.description,
    this.type,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'date': date.toString(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> data, String documentID) {
    if (data == null) {
      return null;
    }
    String id = data['id'];
    String title = data['title'];
    String description = data['description'];
    String type = data['type'];
    DateTime date = DateTime.parse(data['date']);
    return Reminder(title: title, description: description, type: type, date: date,id: id);
  }
}

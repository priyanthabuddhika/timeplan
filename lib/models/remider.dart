class Reminder {
  final int id;
  final String title;
  final String description;
  final String type;
  final String date;
  Reminder({this.id, this.title, this.description, this.type, this.date, });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'date': date,
    };
  }
}

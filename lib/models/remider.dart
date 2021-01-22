import 'package:flutter/widgets.dart';

// reminder class
class Reminder {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final IconData icon;
  final Map<String, bool> apps;
  Reminder(
      {this.id,
      this.title,
      this.description,
      this.type,
      this.date,
      this.icon,
      this.apps});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'date': date.toString(),
      'icon': icon.codePoint,
      'apps': apps,
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
    IconData icon = IconData(data['icon'], fontFamily: 'MaterialIcons');
    Map<String, bool> apps = data['apps'];
    return Reminder(
        title: title,
        description: description,
        type: type,
        date: date,
        id: id,
        icon: icon,
        apps: apps);
  }
}

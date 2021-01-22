import 'package:flutter/widgets.dart';

// schedule class
class Schedule {
  final String id;
  final String title;
  final String description;
  final String type;
  final String date;
  final DateTime startTime;
  final DateTime endTime;
  final IconData icon;
  final Map<String, bool> apps;
  Schedule(
      {this.id,
      this.title,
      this.description,
      this.type,
      this.date,
      this.startTime,
      this.endTime,
      this.icon,
      this.apps});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'date': date,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'icon': icon.codePoint,
      'apps': apps,
    };
  }

  factory Schedule.fromMap(Map<String, dynamic> data, String documentID) {
    if (data == null) {
      return null;
    }
    String id = data['id'];
    String title = data['title'];
    String description = data['description'];
    String type = data['type'];
    String date = data['date'];
    DateTime starttime = DateTime.parse(data['startTime']);
    DateTime endTime = DateTime.parse(data['endTime']);
    IconData icon = IconData(data['icon'], fontFamily: 'MaterialIcons');
    Map<String, bool> apps = data['apps'];

    return Schedule(
      title: title,
      description: description,
      type: type,
      date: date,
      id: id,
      startTime: starttime,
      endTime: endTime,
      icon: icon,
      apps: apps,
    );
  }
}

import 'package:flutter/widgets.dart';

class ReminderTypeModel {
  String title;
  IconData icon;
  bool isReminder;

  ReminderTypeModel({this.icon, this.title, this.isReminder});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon': icon.codePoint,
      'isReminder': isReminder,
    };
  }

  factory ReminderTypeModel.fromMap(
      Map<String, dynamic> data, String documentID) {
    if (data == null) {
      return null;
    }
    String title = data['title'];
    IconData icon = IconData(data['icon'], fontFamily: 'MaterialIcons');
    bool isReminder = data['isReminder'];
    return ReminderTypeModel(
      title: title,
      isReminder: isReminder,
      icon: icon,
    );
  }
}

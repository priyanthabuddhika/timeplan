import 'package:flutter/material.dart';

class ReminderIcon{
  static IconData getReminderIcon(String type){
    switch (type) {
      case "Birthday":
        return Icons.cake;
        break;
      case "Lecture":
        return Icons.book;
        break;
      case "Event":
        return Icons.event;
        break;
      case "Assignment":
        return Icons.assignment;
        break;
      case "Shopping":
        return Icons.shopping_basket;
        break;
      case "Meeting":
        return Icons.people;
        break;
      case "Other":
        return Icons.devices_other;
        break;
      default:
        return Icons.devices_other;
        break;
    }
  }
}

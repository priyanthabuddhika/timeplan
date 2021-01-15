import 'package:flutter/material.dart';
import 'package:timeplan/screens/authenticate/Login/login_screen.dart';
import 'package:timeplan/screens/authenticate/Signup/signup_screen.dart';
import 'package:timeplan/screens/home/home.dart';
import 'package:timeplan/screens/note_page.dart';
import 'package:timeplan/screens/reminderpage.dart';
import 'package:timeplan/screens/scheduleaddpage.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiate this object

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String setting = '/setting';
  static const String reminders_page = '/reminderspage';
  static const String schedules_page = '/schedulespage';
  static const String notes_page = '/notespage';

  static final routes = <String, WidgetBuilder>{
    // splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => LoginScreen(),
    register: (BuildContext context) => SignUpScreen(),
    home: (BuildContext context) => Home(),
    reminders_page: (BuildContext context) => ReminderPage(),
    // setting: (BuildContext context) => SettingScreen(),
    // create_edit_todo: (BuildContext context) => CreateEditTodoScreen(),
    schedules_page: (BuildContext context) => SchedulePage(),
    notes_page: (BuildContext context) => NotePage(),
  };
}

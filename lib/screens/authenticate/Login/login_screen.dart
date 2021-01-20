import 'package:flutter/material.dart';
import 'package:timeplan/screens/authenticate/Login/components/body.dart';
// login screen root widget
class LoginScreen extends StatelessWidget {
  final Function toggleView;
  LoginScreen({this.toggleView});
  static const String id = "login";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        toggleView: toggleView,
      ),
    );
  }
}

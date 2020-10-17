import 'package:flutter/material.dart';
import 'package:timeplan/screens/authenticate/Signup/components/body.dart';

class SignUpScreen extends StatelessWidget {
  final Function toggleView;
  static const String id = "signup";
  SignUpScreen({this.toggleView});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(toggleView: toggleView,),
    );
  }
}

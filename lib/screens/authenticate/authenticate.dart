
import 'package:flutter/material.dart';
import 'package:timeplan/screens/authenticate/Login/login_screen.dart';
import 'package:timeplan/screens/authenticate/Signup/signup_screen.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;
  void toggleView(){
    //print(showSignIn.toString());
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return LoginScreen(toggleView:  toggleView);
    } else {
      return SignUpScreen(toggleView:  toggleView);
    }
  }
}
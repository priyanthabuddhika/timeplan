
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/user.dart';
import 'package:timeplan/screens/Welcome/welcome_screen.dart';
import 'package:timeplan/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel>(context);
   
    // return either the Home or Authenticate widget
    if (user == null){
      return WelcomeScreen();
    } else {
       print(user.uid);
      return Home();
    }
    
  }
}
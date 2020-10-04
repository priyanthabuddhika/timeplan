import 'package:flutter/material.dart';
import 'package:timeplan/services/auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Container(
        child: Center(
            child: MaterialButton(
          child: Text("Sign Out"),
          onPressed: _auth.signOut,
        )),
      ),
    );
  }
}

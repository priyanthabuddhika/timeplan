import 'package:flutter/material.dart';
import 'package:timeplan/components/rounded_button.dart';
import 'package:timeplan/screens/authenticate/Login/login_screen.dart';
import 'package:timeplan/screens/authenticate/Signup/signup_screen.dart';
import 'package:timeplan/screens/Welcome/components/background.dart';
import 'package:timeplan/shared/constants.dart';

class WelcomeScreen extends StatelessWidget {

static const String id = "welcome";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "WELCOME TO TIMEPLAN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.05),
              Image.asset(
                'assets/images/logoimg.png',
                height: size.height * 0.45,
              ),
              // SvgPicture.asset(
              //   "assets/icons/chat.svg",
              //   height: size.height * 0.45,
              // ),
              SizedBox(height: size.height * 0.05),
              RoundedButton(
                text: "LOGIN",
                press: () {
                  Navigator.pushNamed(context, LoginScreen.id);
                },
              ),
              RoundedButton(
                text: "SIGN UP",
                color: kPrimaryLightColor,
                textColor: Colors.black,
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignUpScreen();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

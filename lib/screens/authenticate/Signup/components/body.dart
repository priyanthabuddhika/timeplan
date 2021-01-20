import 'package:flutter/material.dart';
import 'package:timeplan/screens/authenticate/Signup/components/background.dart';
import 'package:timeplan/screens/authenticate/Signup/components/social_icon.dart';
import 'package:timeplan/components/already_have_an_account_acheck.dart';
import 'package:timeplan/components/rounded_button.dart';
import 'package:timeplan/services/auth.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/shared/loading.dart';
import 'package:timeplan/shared/regex.dart';

class Body extends StatefulWidget {
  final Function toggleView;
  Body({this.toggleView});
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';

  bool isObscure = true;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return loading
        ? Loading()
        : Background(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: size.height * 0.03),
                    Image.asset(
                      'assets/images/logoimg.png',
                      height: size.height * 0.2,
                    ),
                    SizedBox(height: size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: size.width * 0.1),
                        Text(
                          "Sign up",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                              color: kPrimaryColor),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(29),
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          final emailMatch = emailRegex.stringMatch(value);

                          if (emailMatch == null) {
                            setState(() {
                              error = "Please insert a valid email";
                            });
                          } else {
                            setState(() {
                              error = "";
                            });
                          }

                          setState(() => email = value);
                        },
                        validator: (value) =>
                            value.isEmpty ? 'Enter an email' : null,
                        cursorColor: kPrimaryColor,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.person,
                            color: kPrimaryColor,
                          ),
                          hintText: "Your Email",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(29),
                      ),
                      child: TextFormField(
                        obscureText: isObscure,
                        onChanged: (value) {
                          setState(() => password = value);
                        },
                        validator: (value) => value.length < 6
                            ? 'Enter a password 6+ chars long'
                            : null,
                        cursorColor: kPrimaryColor,
                        decoration: InputDecoration(
                          hintText: "Password",
                          icon: Icon(
                            Icons.lock,
                            color: kPrimaryColor,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                            child: Icon(
                              isObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kPrimaryColor,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: size.width * 0.1),
                        Expanded(
                          child: RoundedButton(
                            text: "Sign up",
                            press: () async {
                              if (_formKey.currentState.validate()) {
                                setState(() => loading = true);
                                dynamic result =
                                    await _auth.registerWithEmailAndPassword(
                                        email, password);
                                if (result == null) {
                                  setState(() {
                                    loading = false;
                                    error = 'Please supply a valid email';
                                  });
                                }
                              }
                            },
                          ),
                        ),
                        SocalIcon(
                            iconSrc: "assets/icons/google-plus.svg",
                            press: () async {
                              setState(() => loading = true);
                              dynamic result = await _auth.googleSignIn();
                              if (result == null) {
                                setState(() {
                                  loading = false;
                                  error = 'Please supply a valid email';
                                });
                              }
                            }),
                        SizedBox(width: size.width * 0.1),
                      ],
                    ),
                    SizedBox(height: size.height * 0.03),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    AlreadyHaveAnAccountCheck(
                      login: false,
                      press: () => widget.toggleView(),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

import 'package:flutter/material.dart';
import 'package:timeplan/screens/authenticate/Login/components/background.dart';
import 'package:timeplan/components/already_have_an_account_acheck.dart';
import 'package:timeplan/components/rounded_button.dart';
import 'package:timeplan/screens/authenticate/Signup/components/or_divider.dart';
import 'package:timeplan/screens/authenticate/Signup/components/social_icon.dart';
import 'package:timeplan/services/auth.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/shared/loading.dart';

class Body extends StatefulWidget {
  final Function toggleView;

  const Body({Key key, this.toggleView}) : super(key: key);

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
                    Text(
                      "LOGIN",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Image.asset(
                      'assets/images/logoimg.png',
                      height: size.height * 0.35,
                    ),
                    // SvgPicture.asset(
                    //   "assets/icons/login.svg",
                    //   height: size.height * 0.35,
                    // ),
                    SizedBox(height: size.height * 0.03),
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
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                        validator: (val) =>
                            val.isEmpty ? 'Enter an email' : null,
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
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                        validator: (val) => val.length < 6
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

                    RoundedButton(
                      text: "LOGIN",
                      press: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() => loading = true);
                          dynamic result = await _auth
                              .signInWithEmailAndPassword(email, password);
                          if (result == null) {
                            setState(() {
                              loading = false;
                              error = 'Please supply a valid email';
                            });
                          }
                        }
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    AlreadyHaveAnAccountCheck(
                      press: widget.toggleView,
                    ),
                    OrDivider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

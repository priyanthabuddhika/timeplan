import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timeplan/services/auth.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/shared/loading.dart';
// profile page
class ProfileScreen extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = auth.getUser;

    if (user != null) {
      return Scaffold(
        backgroundColor: kPrimaryBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            "Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              user.photoURL != null
                  ? CircleAvatar(
                      foregroundColor: Colors.white,
                      radius: 100,
                      backgroundImage: NetworkImage(
                        user.photoURL,
                      ),
                    )
                  : SizedBox(
                      height: 100.0,
                      child: SvgPicture.asset(
                        'assets/icons/avatar.svg',
                        fit: BoxFit.contain,
                      )),
              kSizedBox,
              kSizedBox,
              Text(user.email ?? '',
                  style: Theme.of(context).textTheme.headline5),
              Spacer(),
              Spacer(),
              FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kContainerBorderRadius),
                  ),
                  child: Text(
                    'Sign out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  color: Colors.red,
                  onPressed: () async {
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.confirm,
                      cancelBtnTextStyle: TextStyle(color: kGradientColorOne),
                      title: "Do you want to sign out ?",
                      confirmBtnText: "Yes",
                      confirmBtnColor: Colors.red,
                      onConfirmBtnTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pop(true);
                      },
                    );
                  }),
              Spacer()
            ],
          ),
        ),
      );
    } else {
      return Loading();
    }
  }
}

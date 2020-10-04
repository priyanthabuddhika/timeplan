import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timeplan/models/user.dart';
import 'package:timeplan/screens/wrapper.dart';
import 'package:timeplan/services/auth.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: AuthService().user,
      child: MaterialApp(
        // navigatorObservers: [
        //   FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
        // ],
        // Firebase Analytics
        title: 'Timeplan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
        ),

        // Named Routes
        // routes: {
        //   '/': (context) => LoginScreen(),
        //   '/topics': (context) => TopicsScreen(),
        //   '/profile': (context) => ProfileScreen(),
        //   '/about': (context) => AboutScreen(),
        // },

        home: Wrapper(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/user.dart';
import 'package:timeplan/providers/auth_provider.dart';
import 'package:timeplan/providers/language_provider.dart';
import 'package:timeplan/providers/theme_provider.dart';
import 'package:timeplan/screens/auth_widget_builder.dart';
import 'package:timeplan/screens/authenticate/Login/login_screen.dart';
import 'package:timeplan/screens/authenticate/Signup/signup_screen.dart';
import 'package:timeplan/screens/authenticate/authenticate.dart';
import 'package:timeplan/screens/calendarpage.dart';
import 'package:timeplan/screens/fullscheduolepage.dart';
import 'package:timeplan/screens/home/home.dart';
import 'package:timeplan/screens/note_page.dart';
import 'package:timeplan/screens/notesfullpage.dart';
import 'package:timeplan/screens/reminderpage.dart';
import 'package:timeplan/screens/scheduleaddpage.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({Key key, this.databaseBuilder}) : super(key: key);

//   // Expose builders for 3rd party services at the root of the widget tree
//   // This is useful when mocking services while testing
//   final FirestoreDatabase Function(BuildContext context, String uid)
//       databaseBuilder;

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return StreamProvider<UserModel>.value(
//       value: AuthService().user,
//       child: MaterialApp(
//         // navigatorObservers: [
//         //   FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
//         // ],
//         // Firebase Analytics
//         title: 'Timeplan',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primaryColor: kPrimaryColor,
//           scaffoldBackgroundColor: Colors.white,
//         ),
//         // Named Routes
//         // routes: {
//         //   Home.id: (context) => Home(),
//         //   WelcomeScreen.id: (context) => WelcomeScreen(),
//         //   LoginScreen.id: (context) => LoginScreen(),
//         //   SignUpScreen.id: (context) => SignUpScreen(),
//         // },
//         home: Wrapper(),
//       ),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.databaseBuilder}) : super(key: key);

  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProviderRef, __) {
        //{context, data, child}
        return Consumer<LanguageProvider>(
          builder: (_, languageProviderRef, __) {
            return AuthWidgetBuilder(
              databaseBuilder: databaseBuilder,
              builder: (BuildContext context,
                  AsyncSnapshot<UserModel> userSnapshot) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: languageProviderRef.appLocale,
                  //List of all supported locales
                  supportedLocales: [
                    Locale('en', 'US'),
                  ],
                  //These delegates make sure that the localization data for the proper language is loaded
                  localizationsDelegates: [
                    //A class which loads the translations from JSON files
                    AppLocalizations.delegate,
                    //Built-in localization of basic text for Material widgets (means those default Material widget such as alert dialog icon text)
                    GlobalMaterialLocalizations.delegate,
                    //Built-in localization for text direction LTR/RTL
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  //return a locale which will be used by the app
                  localeResolutionCallback: (locale, supportedLocales) {
                    //check if the current device locale is supported or not
                    for (var supportedLocale in supportedLocales) {
                      if (supportedLocale.languageCode ==
                              locale?.languageCode ||
                          supportedLocale.countryCode == locale?.countryCode) {
                        return supportedLocale;
                      }
                    }
                    //if the locale from the mobile device is not supported yet,
                    //user the first one from the list (in our case, that will be English)
                    return supportedLocales.first;
                  },
                  title: 'Timeplan',
                  theme: ThemeData(
                      primaryColor: Color(0xFF7113D0),
                      primaryColorLight: kPrimaryColor,
                      accentColor: kPrimaryColor,
                      timePickerTheme: TimePickerThemeData()),
                  // routes: Routes.routes,
                  onGenerateRoute: (settings) {
                    switch (settings.name) {
                      case '/login':
                        return PageTransition(
                          child: LoginScreen(),
                          type: PageTransitionType.scale,
                          settings: settings,
                        );
                        break;
                      case '/register':
                        return PageTransition(
                          child: SignUpScreen(),
                          type: PageTransitionType.scale,
                          settings: settings,
                        );
                        break;
                      case '/home':
                        return PageTransition(
                          child: Home(),
                          type: PageTransitionType.scale,
                          settings: settings,
                        );
                        break;
                      case '/notespage':
                        return PageTransition(
                          child: NotePage(),
                          type: PageTransitionType.scale,
                          settings: settings,
                        );
                        break;

                      case '/schedulespage':
                        return PageTransition(
                          child: SchedulePage(),
                          type: PageTransitionType.bottomToTop,
                          settings: settings,
                          duration: Duration(milliseconds: 400),
                          reverseDuration: Duration(milliseconds: 300),
                        );
                        break;
                      case '/reminderspage':
                        return PageTransition(
                          child: ReminderPage(),
                          type: PageTransitionType.bottomToTop,
                          settings: settings,
                          duration: Duration(milliseconds: 400),
                          reverseDuration: Duration(milliseconds: 300),
                        );
                        break;
                      case '/calendarpage':
                        return PageTransition(
                          child: CalendarView(),
                          type: PageTransitionType.rightToLeft,
                          settings: settings,
                          duration: Duration(milliseconds: 400),
                          reverseDuration: Duration(milliseconds: 300),
                        );
                        break;
                      case '/fullschedulepage':
                        return PageTransition(
                          child: FullSchedulePage(),
                          type: PageTransitionType.rightToLeft,
                          settings: settings,
                          duration: Duration(milliseconds: 400),
                          reverseDuration: Duration(milliseconds: 300),
                        );
                        break;
                      case '/notesfullpage':
                        return PageTransition(
                          child: NotesFullPage(),
                          type: PageTransitionType.rightToLeft,
                          settings: settings,
                          duration: Duration(milliseconds: 400),
                          reverseDuration: Duration(milliseconds: 300),
                        );
                        break;
                      default:
                        return null;
                    }
                  },
                  home: Consumer<AuthProvider>(
                    builder: (_, authProviderRef, __) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.active) {
                        return userSnapshot.hasData ? Home() : Authenticate();
                      }

                      return Material(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

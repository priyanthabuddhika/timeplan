import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeplan/models/schedule.dart';
import 'package:timeplan/models/user.dart';
import 'package:timeplan/providers/auth_provider.dart';
import 'package:timeplan/screens/home/empty_content.dart';
import 'package:timeplan/screens/home/widgets/NoteViewWidget.dart';
import 'package:timeplan/screens/home/widgets/RemindersViewWidget.dart';
import 'package:timeplan/screens/home/widgets/ScheduleViewWidget.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/shared/routes.dart';
import 'package:timeplan/shared/typeIcon.dart';

class Home extends StatelessWidget {
  static const String id = "home";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kPrimaryBackgroundColor,
      // appBar: AppBar(
      //   title: StreamBuilder(
      //       stream: authProvider.user,
      //       builder: (context, snapshot) {
      //         final UserModel user = snapshot.data;
      //         return Text(user != null
      //             ? user.email +
      //                 " - " +
      //                 AppLocalizations.of(context).translate("homeAppBarTitle")
      //             : AppLocalizations.of(context).translate("homeAppBarTitle"));
      //       }),
      //   actions: <Widget>[
      //     StreamBuilder(
      //         stream: firestoreDatabase.remindersStream(),
      //         builder: (context, snapshot) {
      //           if (snapshot.hasData) {
      //             List<Reminder> todos = snapshot.data;
      //             return Visibility(
      //                 visible: todos.isNotEmpty ? true : false,
      //                 child: TodosExtraActions());
      //           } else {
      //             return Container(
      //               width: 0,
      //               height: 0,
      //             );
      //           }
      //         }),
      //     IconButton(
      //         icon: Icon(Icons.settings),
      //         onPressed: () {
      //           Navigator.of(context).pushNamed(Routes.setting);
      //         }),
      //   ],
      // ),
      floatingActionButton: SpeedDial(
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.add_event,
        animatedIconTheme: IconThemeData(size: 22.0),
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: kGradientColorOne,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.alarm_add),
            backgroundColor: kGradientColorTwo,
            label: 'Add reminder',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.of(context).pushNamed(Routes.reminders_page),
          ),
          SpeedDialChild(
            child: Icon(Icons.schedule),
            backgroundColor: kGradientColorTwo,
            label: 'Update schedule',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.of(context).pushNamed(Routes.schedules_page),
          ),
          SpeedDialChild(
            child: Icon(Icons.note_add),
            backgroundColor: kGradientColorTwo,
            label: 'Add note',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => Navigator.of(context).pushNamed(Routes.notes_page),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildContent(
          context,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildAppBar(context),
              _buildNextEvent(context),
              // _buildBodySection(context),
              kSizedBox,
              RemindersViewWidget(context: context),
              kSizedBox,
              ScheduleViewWidget(context: context),
              kSizedBox,
              NoteViewWidget(context: context),
            ],
          )),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return StreamBuilder(
        stream: authProvider.user,
        builder: (context, snapshot) {
          final UserModel user = snapshot.data;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user != null && user.photoURL != null
                  ? NetworkImage(
                      user.photoURL,
                    )
                  : AssetImage('/assets/images/avatar.png'),
              child: Icon(Icons.person),
            ),
            title: Text(
              'Hello,',
            ),
            subtitle: user != null && user.displayName != null
                ? Text(
                    user.displayName,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )
                : Text(
                    "There!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
            contentPadding: EdgeInsets.only(left: 10.0),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              IconButton(
                icon: Icon(Icons.message),
                color: kPrimaryColor,
                onPressed: () {},
              ),
              IconButton(
                  icon: Icon(Icons.settings),
                  color: kPrimaryColor,
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  })
            ]),
          );
        });
  }

  Widget _buildNextEvent(BuildContext context) {
    final _firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    DateTime date = DateTime.now();
    return StreamBuilder(
      stream: _firestoreDatabase.nextEvent(
        day: date,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Schedule> event = snapshot.data;
          if (event.isNotEmpty) {
            Schedule nextEvent = event[0];
            return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/schedulespage', arguments: event[0]);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kContainerBorderRadius),
                  color: Colors.white,
                ),
                margin: EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [kGradientColorOne, kGradientColorTwo]),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(kContainerBorderRadius),
                              bottomLeft:
                                  Radius.circular(kContainerBorderRadius),
                              topRight: Radius.circular(kContainerBorderRadius),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Next Event',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              "${TimeOfDay.fromDateTime(nextEvent.startTime).format(context)} - ${TimeOfDay.fromDateTime(nextEvent.endTime).format(context)}",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 8.0),
                            Icon(
                              Icons.watch_later,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      kSizedBox,
                      Container(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      nextEvent.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Icon(
                                    ReminderIcon.getReminderIcon(
                                        nextEvent.type),
                                    color: kPrimaryColor,
                                  )
                                ]),
                            kSizedBox,
                            Text(
                              'View',
                              style:
                                  TextStyle(fontSize: 10.0, color: Colors.grey),
                            ),
                            Text(
                              nextEvent.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.zoom_in,
                                  color: Colors.grey,
                                ),
                                Text(
                                  'Zoom Linked - Meeting 663',
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ]),
              ),
            );
          } else {
            return EmptyContentWidget(
              title: AppLocalizations.of(context)
                  .translate("todosEmptyTopMsgDefaultTxt"),
              message: AppLocalizations.of(context)
                  .translate("todosEmptyBottomDefaultMsgTxt"),
            );
          }
        } else if (snapshot.hasError) {
          print("jjdfjf" + snapshot.error.toString());
          return EmptyContentWidget(
            title:
                AppLocalizations.of(context).translate("todosErrorTopMsgTxt"),
            message: AppLocalizations.of(context)
                .translate("todosErrorBottomMsgTxt"),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

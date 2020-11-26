import 'package:flutter/material.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/models/user.dart';
import 'package:timeplan/providers/auth_provider.dart';
import 'package:timeplan/screens/home/empty_content.dart';
import 'package:timeplan/screens/home/reminders_extra_actions.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/shared/routes.dart';

class Home extends StatelessWidget {
  static const String id = "home";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kPrimaryLightColor,
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(
            Routes.reminders_page,
          );
        },
      ),
      body: WillPopScope(
          onWillPop: () async => false,
          child: SafeArea(
            child: _buildContent(
              context,
            ),
          )),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildAppBar(context),
              _buildNextEvent(context),
              _buildBodySection(context),
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
              child: user != null && user.photoURL != null
                  ? NetworkImage(user.photoURL)
                  : FlutterLogo(),
            ),
            title: Text('Hello'),
            subtitle: Text(user != null && user.displayName != ""
                ? user.displayName
                : "there!"),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              IconButton(
                icon: Icon(Icons.message),
                color: kPrimaryColor,
                onPressed: () {},
              ),
              IconButton(
                  icon: Icon(Icons.settings),
                  color: kPrimaryColor,
                  onPressed: () {})
            ]),
          );
        });
  }

  Widget _buildNextEvent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.white,
      ),
      margin: EdgeInsets.all(8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
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
                    '10.00p.m.',
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
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Mystic Arts Lecture",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black),
                        ),
                        Icon(
                          Icons.library_books,
                          color: kPrimaryColor,
                        )
                      ]),
                  SizedBox(height: 10.0),
                  Text(
                    'View',
                    style: TextStyle(fontSize: 10.0),
                  ),
                  Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In fermentum quam arcu, id auctor sem sodales vel. Donec euismod bibendum elementum. Mauris tempus purus eget pretium vehicula. ')
                ,SizedBox(height: 10.0,)
               
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ]),
    );
  }

  Widget _buildBodySection(BuildContext context) {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    return StreamBuilder(
        stream: firestoreDatabase.remindersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Reminder> reminders = snapshot.data;
            if (!reminders.isNotEmpty) {
              //   return ListView.separated(
              //     scrollDirection: ,
              //     itemCount: reminders.length,
              //     itemBuilder: (context, index) {
              //       return Dismissible(
              //         background: Container(
              //           color: Colors.red,
              //           child: Center(
              //               child: Text(
              //             AppLocalizations.of(context)
              //                 .translate("remindersDismissibleMsgTxt"),
              //             style: TextStyle(color: Theme.of(context).canvasColor),
              //           )),
              //         ),
              //         key: Key(reminders[index].id),
              //         onDismissed: (direction) {
              //           firestoreDatabase.deleteReminder(reminders[index]);

              //           _scaffoldKey.currentState.showSnackBar(SnackBar(
              //             backgroundColor: Theme.of(context).appBarTheme.color,
              //             content: Text(
              //               AppLocalizations.of(context)
              //                       .translate("todosSnackBarContent") +
              //                   reminders[index].title,
              //               style:
              //                   TextStyle(color: Theme.of(context).canvasColor),
              //             ),
              //             duration: Duration(seconds: 3),
              //             action: SnackBarAction(
              //               label: AppLocalizations.of(context)
              //                   .translate("todosSnackBarActionLbl"),
              //               textColor: Theme.of(context).canvasColor,
              //               onPressed: () {
              //                 firestoreDatabase.setreminder(reminders[index]);
              //               },
              //             ),
              //           ));
              //         },
              //         child: ListTile(
              //           // leading: Checkbox(
              //           //     // value: reminders[index].complete,
              //           //     // onChanged: (value) {
              //           //     //   TodoModel todo = TodoModel(
              //           //     //       id: reminders[index].id,
              //           //     //       task: reminders[index].task,
              //           //     //       extraNote: reminders[index].extraNote,
              //           //     //       complete: value);
              //           //     //   firestoreDatabase.setTodo(todo);
              //           //     // },
              //           //     ),
              //           title: Text(reminders[index].title),
              //           onTap: () {
              //             Navigator.of(context).pushNamed(Routes.reminders_page,
              //                 arguments: reminders[index]);
              //           },
              //         ),
              //       );
              //     },
              //     separatorBuilder: (context, index) {
              //       return Divider(height: 0.5);
              //     },
              //   );
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
        });
  }
}
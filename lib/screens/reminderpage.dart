import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/shared/typeWidget.dart';

// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/standalone.dart' as tz;

class ReminderPage extends StatefulWidget {
  static const String id = "reminderspage";
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  // DatabaseHelper _dbHelper = DatabaseHelper();
  Reminder _reminder;

  TextEditingController _titleController;
  TextEditingController _descriptionController;

  String _reminderType;
  IconData iconData;
  FocusNode _titleFocus;
  FocusNode _descriptionFocus;

  DateTime selectedDate;
  TimeOfDay selectedTime;

  bool _initCompleted;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: selectedDate,
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        // print(picked.toString());
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    DateTime dateTimeTemp;
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      dateTimeTemp = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, picked.hour, picked.minute);

      setState(() {
        selectedDate = dateTimeTemp;
        selectedTime = picked;
        print(selectedDate.toString());
      });
    }
  }

  @override
  void initState() {
    // _reminder =  Reminder();
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();

    selectedDate = DateTime.now();
    print(selectedDate.toLocal().toString());
    selectedTime = TimeOfDay.now();

    _reminderType = "";

    _initCompleted = false;

    super.initState();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _titleController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Reminder _reminderModel = ModalRoute.of(context).settings.arguments;
    if (_reminderModel != null) {
      _reminder = _reminderModel;
      _reminderType = _reminderModel.type;
      iconData = _reminderModel.icon;
      selectedDate = _reminderModel.date;
    }
    if (!_initCompleted) {
      _titleController =
          TextEditingController(text: _reminder != null ? _reminder.title : "");
      _descriptionController = TextEditingController(
          text: _reminder != null ? _reminder.description : "");
      _initCompleted = true;
    }
  }

  void saveToFirestore() {
    print(_reminderType);
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();

      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      firestoreDatabase.setreminder(Reminder(
        id: _reminder != null ? _reminder.id : documentIdFromCurrentDate(),
        title: _titleController.text,
        description: _descriptionController.text.length > 0
            ? _descriptionController.text
            : "",
        type: _reminderType != "" ? _reminderType : "Other",
        date: selectedDate,
        icon: iconData != null ? iconData : Icons.devices_other,
      ));
      // scheduleAlarm(selectedDate, _titleController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Future<bool> _onWillPop() {
      if (_titleController.text != "") {
        return CoolAlert.show(
          context: context,
          type: CoolAlertType.confirm,
          text: "Your reminder will not be saved",
          cancelBtnText: "Save",
          onCancelBtnTap: () {
            saveToFirestore();
            Navigator.of(context).pop(true);
          },
          confirmBtnColor: Colors.red,
          confirmBtnText: "Yes",
          cancelBtnTextStyle:
              TextStyle(color: kGradientColorOne, fontWeight: FontWeight.bold),
          onConfirmBtnTap: () {
            Navigator.of(context).pop(true);
            Navigator.of(context).pop(true);
          },
        );
      } else {
        return Future.delayed(Duration(milliseconds: 1), () {
          return true;
        });
      }
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color(0xFFF6F6F6),
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black, //change your color here
            ),
            elevation: 0,
            backgroundColor: Color(0xFFF6F6F6),
            title: Text(
              _reminder != null ? kEditReminder : kAddReminder,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: kGradientColorTwo, fontWeight: FontWeight.bold),
                  ),
                )),
                onTap: () {
                  saveToFirestore();
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      bottom: 20.0,
                      left: 20.0,
                      right: 20.0,
                      top: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          kBoxDecorationRadius), //Color(0xFFF6F6F6),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        "Reminder Type",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "$_reminderType",
                      ),
                      trailing:
                          IconButton(icon: Icon(Icons.add), onPressed: null),
                      children: [
                        Container(
                          child: ReminderTypeWidget(
                            isReminder: true,
                            previousType: _reminderType,
                            onValueChanged: (value) async {
                              if (value != "") {
                                setState(() {
                                  print(value);
                                  _reminderType = value;
                                });
                              }
                            },
                            onIconChanged: (value) async {
                              if (value != null) {
                                setState(() {
                                  print(value);
                                  iconData = value;
                                });
                              }
                            },
                          ),
                        ),
                        kSizedBox,
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              margin:
                                  EdgeInsets.only(bottom: 20.0, right: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    kBoxDecorationRadius), //Color(0xFFF6F6F6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      'Due date',
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      "${selectedDate.toLocal()}"
                                              .split(' ')[0] +
                                          "",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _selectTime(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              margin: EdgeInsets.only(bottom: 20.0, left: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    kBoxDecorationRadius), //Color(0xFFF6F6F6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      'Time',
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      "${selectedTime.format(context)}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(
                      bottom: 20.0,
                      left: 20.0,
                      right: 20.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          kBoxDecorationRadius), //Color(0xFFF6F6F6),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                            child: Text(
                              'Title',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: size.width * 0.9,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(kBoxDecorationRadius),
                                border: Border.all(color: Colors.blueAccent)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _titleController,
                                    focusNode: _titleFocus,
                                    onFieldSubmitted: (value) =>
                                        _descriptionFocus.requestFocus(),
                                    validator: (value) => value.isEmpty
                                        ? AppLocalizations.of(context).translate(
                                            "todosCreateEditTaskNameValidatorMsg")
                                        : null,
                                    decoration: InputDecoration(
                                      hintText: "Enter Reminder Title",
                                      border: InputBorder.none,
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF211551),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                            child: Text(
                              'Description',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            width: size.width * 0.9,
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(kBoxDecorationRadius),
                                border: Border.all(color: Colors.blueAccent)),
                            child: TextFormField(
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 15,
                              focusNode: _descriptionFocus,
                              // onChanged: (value) async {},
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                hintText:
                                    "Enter Description for the reminder...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () async {
              Reminder _reminderToDelete =
                  ModalRoute.of(context).settings.arguments;
              print("delete:" + _reminderToDelete.id);
              if (_reminderToDelete != null) {
                final firestoreDatabase =
                    Provider.of<FirestoreDatabase>(context, listen: false);
                firestoreDatabase.deleteReminder(_reminderToDelete);

                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)
                              .translate("todosSnackBarContent") +
                          _reminderToDelete.title,
                      style: TextStyle(color: Theme.of(context).canvasColor),
                    ),
                    duration: Duration(seconds: 3),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)
                          .translate("todosSnackBarActionLbl"),
                      textColor: Theme.of(context).canvasColor,
                      onPressed: () {
                        firestoreDatabase.setreminder(_reminderToDelete);
                        Future.delayed(Duration(seconds: 3))
                            .then((value) => Navigator.pop(context));
                      },
                    ),
                  ),
                );
                Future.delayed(Duration(seconds: 3))
                    .then((value) => Navigator.pop(context));
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(Icons.delete_forever),
          ),
        ),
      ),
    );
  }

  // void scheduleAlarm(
  //     DateTime scheduledNotificationDateTime, String reminderInfo) async {
  //   final timeZone = new TimeZone();

  //   // The device's timezone.
  //   String timeZoneName = await timeZone.getTimeZoneName();

  //   // Find the 'current location'
  //   final location = await timeZone.getLocation(timeZoneName);

  //   // ignore: unused_local_variable
  //   final scheduledDate = tz.TZDateTime.from(selectedDate, location);

  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'alarm_notif',
  //     'alarm_notif',
  //     'Channel for Alarm notification',
  //     icon: 'ic_local_icon',
  //   );

  //   // ignore: unused_local_variable
  //   var platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //   );

  //   // await flutterLocalNotificationsPlugin.zonedSchedule(
  //   //     0, 'Office', reminderInfo, scheduledDate, platformChannelSpecifics,
  //   //     uiLocalNotificationDateInterpretation:
  //   //         UILocalNotificationDateInterpretation.absoluteTime,
  //   //     androidAllowWhileIdle: true);
  // }
}

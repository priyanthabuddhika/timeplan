import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/remindertype.dart';
import 'package:timeplan/models/schedule.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/shared/typeWidget.dart';

class SchedulePage extends StatefulWidget {
  static const String id = "schedulespage";
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  // DatabaseHelper _dbHelper = DatabaseHelper();
  Schedule _schedule;

  TextEditingController _titleController;
  TextEditingController _descriptionController;

  String _scheduleType;
  String _weekDay;

  FocusNode _titleFocus;
  FocusNode _descriptionFocus;
  DateTime startTime;
  DateTime endTime;
  TimeOfDay selectedTime;

  bool _initCompleted;

  List<String> weekDayList;

  Future<void> _selectStartTime(BuildContext context) async {
    DateTime dateTimeTemp;
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startTime),
    );
    if (picked != null && picked != TimeOfDay.fromDateTime(startTime)) {
      dateTimeTemp = DateTime(startTime.year, startTime.month, startTime.day,
          picked.hour, picked.minute);

      setState(() {
        startTime = dateTimeTemp;
        print(startTime.toString());
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    DateTime dateTimeTemp;
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endTime),
    );
    if (picked != null && picked.hour < startTime.hour) {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          title: "Error",
          borderRadius: 15.0,
          confirmBtnColor: kGradientColorOne,
          text: "End time is lower than start time!");
    } else if (picked != null && picked != TimeOfDay.fromDateTime(endTime)) {
      dateTimeTemp = DateTime(
          endTime.year, endTime.month, endTime.day, picked.hour, picked.minute);

      setState(() {
        endTime = dateTimeTemp;
        print(startTime.toString());
      });
    }
  }

  @override
  void initState() {
    // _schedule =  Schedule();
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();

    startTime = DateTime.now();
    endTime = startTime.add(Duration(hours: 1));

    _scheduleType = "";
    _weekDay = "";
    weekDayList = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];

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
    final Schedule _scheduleModel = ModalRoute.of(context).settings.arguments;
    if (_scheduleModel != null) {
      _schedule = _scheduleModel;
      _scheduleType = _scheduleModel.type;
      _weekDay = _scheduleModel.date;
      startTime = _scheduleModel.startTime;
      endTime = _scheduleModel.endTime;
    }
    if (!_initCompleted) {
      _titleController =
          TextEditingController(text: _schedule != null ? _schedule.title : "");
      _descriptionController = TextEditingController(
          text: _schedule != null ? _schedule.description : "");
      _initCompleted = true;
    }
  }

  void saveToFirestore() {
    print(_scheduleType);
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();

      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      firestoreDatabase.setSchedule(Schedule(
        id: _schedule != null ? _schedule.id : documentIdFromCurrentDate(),
        title: _titleController.text,
        description: _descriptionController.text.length > 0
            ? _descriptionController.text
            : "",
        type: _scheduleType != "" ? _scheduleType : "Other",
        date: _weekDay,
        startTime: startTime,
        endTime: endTime,
      ));

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
          text: "Your schedule will not be saved",
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
              _schedule != null ? kUpdateSchedule : kUpdateSchedule,
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
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                color: Color(0xFFF6F6F6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        bottom: 20.0,
                        top: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(10), //Color(0xFFF6F6F6),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          "Schedule Type",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(_scheduleType),
                        trailing:
                            IconButton(icon: Icon(Icons.add), onPressed: null),
                        children: [
                          Container(
                            child: ReminderTypeWidget(
                              isReminder: false,
                              previousType: _scheduleType,
                              onValueChanged: (value) async {
                                if (value != "") {
                                  setState(() {
                                    print(value);
                                    _scheduleType = value;
                                  });
                                }
                              },
                            ),
                          ),
                          kSizedBox,
                        ],
                      ),
                    ),
                    Container(
                      width: size.width * 0.9,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      margin: EdgeInsets.only(
                        bottom: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(10), //Color(0xFFF6F6F6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Week Day",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          kSizedBox,
                          WeekDayTypeWidget(
                            previousType: _weekDay,
                            onValueChanged: (value) async {
                              if (value != "") {
                                setState(() {
                                  print(value);
                                  _weekDay = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              _selectStartTime(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              margin: EdgeInsets.only(bottom: 20.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10), //Color(0xFFF6F6F6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      'Start Time',
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      "${TimeOfDay.fromDateTime(startTime).format(context)}",
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
                              _selectEndTime(context);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.0),
                              margin: EdgeInsets.only(bottom: 20.0, left: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10), //Color(0xFFF6F6F6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      'End Time',
                                      style: TextStyle(fontSize: 15.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      "${TimeOfDay.fromDateTime(endTime).format(context)}",
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
                    Container(
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.only(
                        bottom: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(10), //Color(0xFFF6F6F6),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 8.0),
                              child: Text(
                                'Title',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              width: size.width * 0.9,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(29),
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
                                        hintText: "Enter Title",
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        color: Color(0xFF211551),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 8.0),
                              child: Text(
                                'Description',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              width: size.width * 0.9,
                              height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(29),
                                  border: Border.all(color: Colors.blueAccent)),
                              child: TextFormField(
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 15,
                                focusNode: _descriptionFocus,
                                // onChanged: (value) async {},
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  hintText:
                                      "Enter Description for the schedule...",
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
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () async {
              Schedule _scheduleToDelete =
                  ModalRoute.of(context).settings.arguments;
              print("delete:" + _scheduleToDelete.id);
              if (_scheduleToDelete != null) {
                final firestoreDatabase =
                    Provider.of<FirestoreDatabase>(context, listen: false);
                firestoreDatabase.deleteSchedule(_scheduleToDelete);

                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)
                              .translate("todosSnackBarContent") +
                          _scheduleToDelete.title,
                      style: TextStyle(color: Theme.of(context).canvasColor),
                    ),
                    duration: Duration(seconds: 3),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)
                          .translate("todosSnackBarActionLbl"),
                      textColor: Theme.of(context).canvasColor,
                      onPressed: () {
                        firestoreDatabase.setSchedule(_scheduleToDelete);
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
}

class WeekDayTypeWidget extends StatefulWidget {
  final ValueChanged<String> onValueChanged;
  final String previousType;

  WeekDayTypeWidget({this.onValueChanged, this.previousType});

  @override
  _WeekDayTypeWidgetState createState() => _WeekDayTypeWidgetState();
}

class _WeekDayTypeWidgetState extends State<WeekDayTypeWidget> {
  String scheduleType;
  int _selectedIndex;
  List<String> _weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  Widget _buildChips() {
    List<Widget> chips = new List();

    for (int i = 0; i < _weekdays.length; i++) {
      if ((widget.previousType != "" || _selectedIndex != null) &&
          _weekdays[i] == widget.previousType) {
        _selectedIndex = i;
      }
      ChoiceChip choiceChip = ChoiceChip(
        selected: _selectedIndex == i,

        label: Text(
          _weekdays[i].substring(0, 1),
          style: TextStyle(
              color: _selectedIndex == i ? Colors.white : Colors.black),
        ),

        // elevation: 10,
        pressElevation: 5,
        // shadowColor: Colors.teal,
        backgroundColor: Colors.transparent,
        shape: CircleBorder(side: BorderSide(color: kGradientColorOne)),
        // shape: StadiumBorder(side: BorderSide(color: Colors.purple)),
        selectedColor: kPrimaryColor,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedIndex = i;
            }
            widget.onValueChanged(_weekdays[i]);
          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 5), child: choiceChip));
    }

    return Wrap(
      // This next line does the trick.
      children: chips,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildChips();
  }
}

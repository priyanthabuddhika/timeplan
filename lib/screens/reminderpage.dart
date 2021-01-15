
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/remindertype.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/services/app_localizations.dart';

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

  FocusNode _titleFocus;
  FocusNode _descriptionFocus;

  DateTime selectedDate;
  TimeOfDay selectedTime;

  bool _initCompleted;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
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
      dateTimeTemp = selectedDate.add(
        Duration(hours: picked.hour, minutes: picked.minute),
      );

      setState(() {
        selectedDate = dateTimeTemp;
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
      ));

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    Future<bool> _onWillPop() {
      if (_titleController.text != "") {
        return showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Are you sure you want to leave?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text('Your reminder will not be saved'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      // saveToFirestore();
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      'Save & exit',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    /*Navigator.of(context).pop(true)*/
                    child: Text(
                      'Yes',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
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
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.blue),
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
                      child: Column(children: <Widget>[
                        ListTile(
                          title: Text(
                            "Reminder Type",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                              icon: Icon(Icons.add), onPressed: null),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                          child: ReminderTypeWidget(
                            previousType: _reminderType,
                            onValueChanged: (value) async {
                              if (value != "") {
                                setState(() {
                                  print(value);
                                  _reminderType = value;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 10.0),
                      ]),
                    ),
                    Row(
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
                                    10), //Color(0xFFF6F6F6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      'Add a due date',
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
                                    10), //Color(0xFFF6F6F6),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0),
                                    child: Text(
                                      'Select Time',
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
                                style: TextStyle(fontSize: 15.0),
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
                                        hintText: "Enter Reminder Title",
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
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
                                style: TextStyle(fontSize: 15.0),
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
                    backgroundColor: Theme.of(context).appBarTheme.color,
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
}

class ReminderTypeWidget extends StatefulWidget {
  final ValueChanged<String> onValueChanged;
  final String previousType;

  ReminderTypeWidget({this.onValueChanged, this.previousType});

  @override
  _ReminderTypeWidgetState createState() => _ReminderTypeWidgetState();
}

class _ReminderTypeWidgetState extends State<ReminderTypeWidget> {
  String reminderType;
  int _selectedIndex;
  List<ReminderTypeModel> _options = [
    ReminderTypeModel(title: 'Birthday', icon: Icons.cake),
    ReminderTypeModel(title: 'Lecture', icon: Icons.book),
    ReminderTypeModel(title: 'Event', icon: Icons.event),
    ReminderTypeModel(title: 'Assigment', icon: Icons.assignment),
    ReminderTypeModel(title: 'Shopping', icon: Icons.shopping_basket),
    ReminderTypeModel(title: 'Meeting', icon: Icons.people),
    ReminderTypeModel(title: 'Other', icon: Icons.devices_other)
  ];

  Widget _buildChips() {
    List<Widget> chips = new List();

    for (int i = 0; i < _options.length; i++) {
      if ((widget.previousType != "" || _selectedIndex != null) &&
          _options[i].title == widget.previousType) {
        _selectedIndex = i;
      }
      ChoiceChip choiceChip = ChoiceChip(
        selected: _selectedIndex == i,

        label: Text(
          _options[i].title,
          style: TextStyle(
              color: _selectedIndex == i ? Colors.white : Colors.black),
        ),
        avatar: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Icon(
            _options[i].icon,
            color: _selectedIndex == i ? Colors.white : Colors.purple,
          ),
        ),
        // elevation: 10,
        pressElevation: 5,
        // shadowColor: Colors.teal,
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(color: Colors.purple)),
        selectedColor: Colors.purple[400],
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedIndex = i;
            }
            widget.onValueChanged(_options[i].title);
          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), child: choiceChip));
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

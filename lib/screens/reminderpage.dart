import 'package:flutter/material.dart';
import 'package:timeplan/models/remindertype.dart';
import 'package:timeplan/services/database_helper.dart';
import 'package:timeplan/models/remider.dart';

class ReminderPage extends StatefulWidget {
  final Reminder reminder;

  ReminderPage({@required this.reminder});

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  DatabaseHelper _dbHelper = DatabaseHelper();

  int _reminderId = 0;
  String _reminderTitle = "";
  String _reminderDescription = "";

  String reminderType = "";

  FocusNode _titleFocus;
  FocusNode _descriptionFocus;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

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
      if (_reminderId != 0) {
        dateTimeTemp = selectedDate.add(Duration(hours: picked.hour, minutes: picked.minute),);
        await _dbHelper.updateReminderDate(
            _reminderId, dateTimeTemp.toString() );
      }

      setState(() {
        selectedDate = dateTimeTemp;
        print(selectedDate.toString());
      });
    }
  }

  @override
  void initState() {
    if (widget.reminder != null) {
      // Set visibility to true

      _reminderTitle = widget.reminder.title;
      _reminderDescription = widget.reminder.description;
      _reminderId = widget.reminder.id;
      reminderType = widget.reminder.type;
      selectedDate = DateTime.parse(widget.reminder.date);
      // TODO : Time date hariyata oni
    }

    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(DateTime.now().toString());
    // print(TimeOfDay.now().format(context));
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        elevation: 0,
        backgroundColor: Color(0xFFF6F6F6),
        title: Text(
          'Add Reminder',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            child: Center(
                child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Text(
                'Done',
                style: TextStyle(color: Colors.blue),
              ),
            )),
            onTap: () {},
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
                      trailing:
                          IconButton(icon: Icon(Icons.add), onPressed: null),
                    ),
                    SizedBox(height: 10.0),
                    Container(child: ReminderTypeWidget(
                      onValueChanged: (value) async {
                        if (value != "") {
                          if (_reminderId != 0) {
                            await _dbHelper.updateReminderType(
                                _reminderId, value);
                            reminderType = value;
                          }
                        }
                      },
                    )),
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
                          margin: EdgeInsets.only(bottom: 20.0, right: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(10), //Color(0xFFF6F6F6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 8.0),
                                child: Text(
                                  'Date',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 8.0),
                                child: Text(
                                  "${selectedDate.toLocal()}".split(' ')[0] +
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
                            borderRadius:
                                BorderRadius.circular(10), //Color(0xFFF6F6F6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 8.0),
                                child: Text(
                                  'Time',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 8.0),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          'Title',
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: size.width * 0.9,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(29),
                            border: Border.all(color: Colors.blueAccent)),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                focusNode: _titleFocus,
                                onSubmitted: (value) async {
                                  // Check if the field is not empty
                                  if (value != "") {
                                    // Check if the task is null
                                    if (widget.reminder == null) {
                                      Reminder _newReminder =
                                          Reminder(title: value);
                                      _reminderId = await _dbHelper
                                          .insertReminder(_newReminder);
                                      setState(() {
                                        _reminderTitle = value;
                                      });
                                    } else {
                                      await _dbHelper.updateReminderTitle(
                                          _reminderId, value);
                                      print("Reminder Updated");
                                    }
                                    _descriptionFocus.requestFocus();
                                  }
                                },
                                controller: TextEditingController()
                                  ..text = _reminderTitle,
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
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          'Description',
                          style: TextStyle(fontSize: 15.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: size.width * 0.9,
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(29),
                            border: Border.all(color: Colors.blueAccent)),
                        child: TextField(
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 100,
                          focusNode: _descriptionFocus,
                          onChanged: (value) async {
                            if (value != "") {
                              if (_reminderId != 0) {
                                await _dbHelper.updateReminderDescription(
                                    _reminderId, value);
                                _reminderDescription = value;
                              }
                            }
                          },
                          controller: TextEditingController()
                            ..text = _reminderDescription,
                          decoration: InputDecoration(
                            hintText: "Enter Description for the reminder...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
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
          if (_reminderId != 0) {
            await _dbHelper.deleteReminder(_reminderId);
            Navigator.pop(context);
          }
        },
        child: Icon(Icons.delete_forever),
      ),
    );
  }
}

class ReminderTypeWidget extends StatefulWidget {
  final ValueChanged<String> onValueChanged;

  ReminderTypeWidget({this.onValueChanged});

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
    ReminderTypeModel(title: 'Meeting', icon: Icons.people)
  ];

  Widget _buildChips() {
    List<Widget> chips = new List();

    for (int i = 0; i < _options.length; i++) {
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

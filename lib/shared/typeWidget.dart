import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/remindertype.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';

class ReminderTypeWidget extends StatefulWidget {
  final ValueChanged<String> onValueChanged;
  final String previousType;
  final bool isReminder;
  ReminderTypeWidget({this.onValueChanged, this.previousType, this.isReminder});

  @override
  _ReminderTypeWidgetState createState() => _ReminderTypeWidgetState();
}

class _ReminderTypeWidgetState extends State<ReminderTypeWidget> {
  String reminderType;
  int _selectedIndex;
  List<ReminderTypeModel> _options;
  Icon _icon;
  bool isAdaptive = true;
  bool showTooltips = false;
  bool showSearch = true;
  @override
  void initState() {
    _icon = Icon(Icons.devices_other);
    if (widget.isReminder) {
      _options = [
        ReminderTypeModel(title: 'Birthday', icon: Icons.cake),
        ReminderTypeModel(title: 'Lecture', icon: Icons.book),
        ReminderTypeModel(title: 'Event', icon: Icons.event),
        ReminderTypeModel(title: 'Assigment', icon: Icons.assignment),
        ReminderTypeModel(title: 'Shopping', icon: Icons.shopping_basket),
        ReminderTypeModel(title: 'Meeting', icon: Icons.people),
        ReminderTypeModel(title: 'Other', icon: Icons.devices_other)
      ];
    } else {
      _options = [
        ReminderTypeModel(title: 'Lecture', icon: Icons.book),
        ReminderTypeModel(title: 'Event', icon: Icons.event),
        ReminderTypeModel(title: 'Meeting', icon: Icons.people),
        ReminderTypeModel(title: 'Other', icon: Icons.devices_other)
      ];
    }
    super.initState();
  }

  TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext contextz) async {
    return showDialog(
        context: contextz,
        builder: (context) {
          Icon iconData = Icon(_icon.icon);
          _pickIcon(BuildContext context) async {
            IconData icon = await FlutterIconPicker.showIconPicker(
              context,
              showTooltips: showTooltips,
              showSearchBar: showSearch,
              iconPickerShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              iconPackMode: IconPack.material,
            );

            if (icon != null) {
              print("III" + icon.codePoint.toString());
              setState(() {
                iconData = Icon(icon);
              });

              debugPrint('Picked Icon:  $icon');
            }
          }

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kContainerBorderRadius),
                ),
                title: Text(
                  widget.isReminder
                      ? 'Add New Reminder Type'
                      : 'Add New Schedule Type',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            valueText = value;
                          });
                        },
                        controller: _textFieldController,
                        decoration: InputDecoration(hintText: "Name"),
                      ),
                    ),
                    kSizedBox,
                    FlatButton.icon(
                        onPressed: () async {
                          await _pickIcon(context);
                          setState(() {
                            iconData = Icon(iconData.icon);
                            _icon = iconData;
                          });
                        },
                        icon: iconData,
                        label: Text(
                          "Select an icon",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
                actions: <Widget>[
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(kContainerBorderRadius),
                    ),
                    textColor: Colors.red,
                    child: Text('Cancel'),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(kContainerBorderRadius),
                    ),
                    color: kGradientColorOne,
                    textColor: Colors.white,
                    child: Text('Add'),
                    onPressed: () {
                      setState(() {
                        codeDialog = valueText;
                        saveToFirestore();
                      });
                    },
                  ),
                  SizedBox(width: 10.0)
                ],
              );
            },
          );
        });
  }

  void saveToFirestore() {
    if (codeDialog.isNotEmpty) {
      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      firestoreDatabase.setType(ReminderTypeModel(
        title: codeDialog,
        icon: _icon.icon,
        isReminder: widget.isReminder,
      ));

      Navigator.of(context).pop();
    }
  }

  String codeDialog;
  String valueText;

  Widget _buildChips(List<ReminderTypeModel> types) {
    for (int i = 0; i < types.length; i++) {
      var existingItemRemindr = _options.firstWhere(
          (itemToCheck) =>
              itemToCheck.title == types[i].title &&
              itemToCheck.isReminder == types[i].isReminder,
          orElse: () => null);
      var existingItemSchedule = _options.firstWhere(
          (itemToCheck) =>
              itemToCheck.title == types[i].title &&
              itemToCheck.isReminder == types[i].isReminder,
          orElse: () => null);
      if (widget.isReminder &&
          existingItemRemindr == null &&
          types[i].isReminder)
        _options.add(types[i]);
      else if (!widget.isReminder &&
          existingItemSchedule == null &&
          !types[i].isReminder) {
        _options.add(types[i]);
      }
    }
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
      if (i == _options.length - 1) {
        chips.add(FlatButton(
          onPressed: () {
            _displayTextInputDialog(context);
          },
          color: kGradientColorTwo,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.purple)),
          child: Text(
            "Add new",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
      }
    }

    return Wrap(
      // This next line does the trick.
      children: chips,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    List<ReminderTypeModel> types;
    return StreamBuilder(
        stream: firestoreDatabase.typesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ReminderTypeModel> types = snapshot.data;
            print(types.length.toString());
            if (types.isNotEmpty) {
              return _buildChips(types);
            } else {
              return _buildChips(types);
            }
          } else {
            types = [];
            return _buildChips(types);
          }
        });
  }
}

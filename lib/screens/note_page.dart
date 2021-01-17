
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/note.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeplan/services/app_localizations.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();
  // DatabaseHelper _dbHelper = DatabaseHelper();
  Note _note;

  TextEditingController _titleController;
  TextEditingController _descriptionController;

  FocusNode _titleFocus;
  FocusNode _descriptionFocus;

  bool _initCompleted;

  @override
  void initState() {
    // _reminder =  Reminder();
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();

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
    final Note _noteModel = ModalRoute.of(context).settings.arguments;
    if (_noteModel != null) {
      _note = _noteModel;
    }
    if (!_initCompleted) {
      _titleController =
          TextEditingController(text: _note != null ? _note.title : "");
      _descriptionController =
          TextEditingController(text: _note != null ? _note.description : "");
      _initCompleted = true;
    }
  }

  void saveToFirestore() {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();

      final firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);

      firestoreDatabase.setNote(Note(
        id: _note != null ? _note.id : documentIdFromCurrentDate(),
        title: _titleController.text,
        description: _descriptionController.text.length > 0
            ? _descriptionController.text
            : "",
        dateUpdated: DateTime.now(),
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
                content: Text('Your note will not be saved'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      saveToFirestore();
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      'Save & exit',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
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
                _note != null ? kUpdateNote : kAddNote,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              margin: EdgeInsets.only(
                                bottom: 20.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    10), //Color(0xFFF6F6F6),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 8.0),
                                      child: Text(
                                        'Title',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      width: size.width * 0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(29),
                                          border: Border.all(
                                              color: Colors.blueAccent)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _titleController,
                                              focusNode: _titleFocus,
                                              onFieldSubmitted: (value) =>
                                                  _descriptionFocus
                                                      .requestFocus(),
                                              validator: (value) => value
                                                      .isEmpty
                                                  ? AppLocalizations.of(context)
                                                      .translate(
                                                          "todosCreateEditTaskNameValidatorMsg")
                                                  : null,
                                              decoration: InputDecoration(
                                                hintText: "Enter Title",
                                                border: InputBorder.none,
                                              ),
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Color(0xFF211551),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 8.0),
                                      child: Text(
                                        'Description',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 5),
                                        width: size.width * 0.9,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(29),
                                            border: Border.all(
                                                color: Colors.blueAccent)),
                                        child: TextFormField(
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 30,
                                          focusNode: _descriptionFocus,
                                          // onChanged: (value) async {},
                                          controller: _descriptionController,
                                          decoration: InputDecoration(
                                            hintText: "Enter Description...",
                                            border: InputBorder.none,
                                          ),
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
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () async {
                Note _noteToDelete = ModalRoute.of(context).settings.arguments;
                print("delete:" + _noteToDelete.id);
                if (_noteToDelete != null) {
                  final firestoreDatabase =
                      Provider.of<FirestoreDatabase>(context, listen: false);
                  firestoreDatabase.deleteNote(_noteToDelete);

                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).appBarTheme.color,
                      content: Text(
                        AppLocalizations.of(context)
                                .translate("todosSnackBarContent") +
                            _noteToDelete.title,
                        style: TextStyle(color: Theme.of(context).canvasColor),
                      ),
                      duration: Duration(seconds: 3),
                      action: SnackBarAction(
                        label: AppLocalizations.of(context)
                            .translate("todosSnackBarActionLbl"),
                        textColor: Theme.of(context).canvasColor,
                        onPressed: () {
                          firestoreDatabase.setNote(_noteToDelete);
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
          )),
    );
  }
}

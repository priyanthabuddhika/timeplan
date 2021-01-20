import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/note.dart';
import 'package:timeplan/screens/home/widgets/empty_content.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/shared/constants.dart';

class NoteViewWidget extends StatefulWidget {
  const NoteViewWidget({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _NoteViewWidgetState createState() => _NoteViewWidgetState(context);
}

class _NoteViewWidgetState extends State<NoteViewWidget> {
  final BuildContext context;
  _NoteViewWidgetState(this.context);

  DateTime date;

  @override
  void initState() {
    super.initState();

    DateTime tempDate = DateTime.now();
    date = new DateTime(tempDate.year, tempDate.month, tempDate.day);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListTile(
        title: Text(
          "Your notes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          SizedBox(width: 10.0),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/notesfullpage',
              );
            },
            child: Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.list),
            ),
          )
        ]),
      ),
      kSizedBox,
      kSizedBox,
      Container(height: 180.0, child: _buildNotesList()),
    ]);
  }

  Widget _buildNotesList() {
    final _firestoreDatabase =
        Provider.of<FirestoreDatabase>(widget.context, listen: false);
    return StreamBuilder(
      stream: _firestoreDatabase.notesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Note> note = snapshot.data;
          if (note.isNotEmpty) {
            return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/notespage', arguments: note[index]);
                    },
                    child: Container(
                      width: 175,
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      margin: EdgeInsets.only(
                          right: 10.0, bottom: 15.0, left: 10.0, top: 10.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note[index].title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                          kSizedBox,
                          Text(
                            "View",
                            style:
                                TextStyle(fontSize: 10.0, color: Colors.grey),
                          ),
                          Text(
                            note[index].description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: note.length);
          } else {
            return EmptyContentWidget(
              title: AppLocalizations.of(context)
                  .translate("todosEmptyTopMsgDefaultTxt"),
              message: AppLocalizations.of(context)
                  .translate("todosEmptyBottomDefaultMsgTxt"),
            );
          }
        } else if (snapshot.hasError) {
          
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/note.dart';
import 'package:timeplan/screens/home/empty_content.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/services/firestore_database.dart';

class NotesFullPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      body: _buildBodySection(context),
    );
  }

  Widget _buildBodySection(BuildContext context) {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    return StreamBuilder(
        stream: firestoreDatabase.notesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Note> notes = snapshot.data;
            if (notes.isNotEmpty) {
              return ListView.separated(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    background: Container(
                      color: Colors.red,
                      child: Center(
                          child: Text(
                        AppLocalizations.of(context)
                            .translate("todosDismissibleMsgTxt"),
                        style: TextStyle(color: Theme.of(context).canvasColor),
                      )),
                    ),
                    key: Key(notes[index].id),
                    onDismissed: (direction) {
                      firestoreDatabase.deleteNote(notes[index]);

                      _scaffoldKey.currentState.showSnackBar(SnackBar(
                   
                        content: Text(
                          AppLocalizations.of(context)
                                  .translate("todosSnackBarContent") +
                              notes[index].title,
                          style:
                              TextStyle(color: Theme.of(context).canvasColor),
                        ),
                        duration: Duration(seconds: 3),
                        action: SnackBarAction(
                          label: AppLocalizations.of(context)
                              .translate("todosSnackBarActionLbl"),
                          textColor: Theme.of(context).canvasColor,
                          onPressed: () {
                            firestoreDatabase.setNote(notes[index]);
                          },
                        ),
                      ));
                    },
                    child: ListTile(
                      title: Text(notes[index].title),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed('/notespage', arguments: notes[index]);
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(height: 0.5);
                },
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

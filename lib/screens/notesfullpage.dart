import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/note.dart';
import 'package:timeplan/screens/home/widgets/empty_content.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';

class NotesFullPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Your notes",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/notespage',
          );
        },
        backgroundColor: kGradientColorOne,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: _buildBodySection(context),
      ),
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
              return StaggeredGridView.countBuilder(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                primary: false,
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(kContainerBorderRadius),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15.0),
                      title: Text(
                        notes[index].title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        notes[index].description,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed('/notespage', arguments: notes[index]);
                      },
                    ),
                  );
                },
                staggeredTileBuilder: (index) => new StaggeredTile.fit(2),
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

import 'package:flutter/material.dart';
import 'package:timeplan/services/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:timeplan/services/firestore_database.dart';

enum TodosActions { toggleAllComplete, clearCompleted }

class TodosExtraActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirestoreDatabase firestoreDatabase = Provider.of(context);


    return PopupMenuButton<TodosActions>(
      icon: Icon(Icons.more_horiz),
      onSelected: (TodosActions result) {
        // switch (result) {
        //   // case TodosActions.toggleAllComplete:
        //   //   firestoreDatabase.setAllTodoComplete();
        //   //   break;
        //   // case TodosActions.clearCompleted:
        //   //   firestoreDatabase.deleteAllTodoWithComplete();
        // }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<TodosActions>>[
        PopupMenuItem<TodosActions>(
          value: TodosActions.toggleAllComplete,
          child: Text(AppLocalizations.of(context).translate("todosPopUpToggleAllComplete")),
        ),
        PopupMenuItem<TodosActions>(
          value: TodosActions.clearCompleted,
          child: Text(AppLocalizations.of(context).translate("todosPopUpToggleClearCompleted")),
        ),
      ],
    );
  }
}

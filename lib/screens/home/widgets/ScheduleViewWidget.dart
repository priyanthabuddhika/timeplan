import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/date_model.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/screens/home/empty_content.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/shared/typeIcon.dart';

class ScheduleViewWidget extends StatefulWidget {
  const ScheduleViewWidget({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _ScheduleViewWidgetState createState() => _ScheduleViewWidgetState(context);
}

class _ScheduleViewWidgetState extends State<ScheduleViewWidget> {
  final BuildContext context;
  _ScheduleViewWidgetState(this.context);

  List<DateModel> dates;
  DateTime date;
  int todayDateIs;
  int _previousIndex;

  @override
  void initState() {
    super.initState();
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    dates = new List<DateModel>();
    DateTime tempDate = DateTime.now();
    date = new DateTime(tempDate.year, tempDate.month, tempDate.day);
    todayDateIs = date.day;
    _previousIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    // ScrollController _scrollController = ScrollController();
    // _scrollToBottom() {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // }

    return Column(children: <Widget>[
      ListTile(
        title: Text(
          "Today Schedule",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            padding: EdgeInsets.all(8),
            child: Icon(Icons.calendar_today),
          ),
          SizedBox(width: 10.0),
          Container(
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            padding: EdgeInsets.all(8),
            child: Icon(Icons.calendar_view_day),
          )
        ]),
      ),
      SizedBox(height: 10.0),
      SizedBox(height: 10.0),
      Container(
        height: 60,
        margin: EdgeInsets.only(left: 8.0),
        child: _buildRemindersList(),
      ),
    ]);
  }

  Widget _buildRemindersList() {
    final _firestoreDatabase =
        Provider.of<FirestoreDatabase>(widget.context, listen: false);
    return StreamBuilder(
      stream: _firestoreDatabase.remindersForDay(
          day: date, datePlus: date.add(Duration(days: 1))),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Reminder> schedule = snapshot.data;
          if (schedule.isNotEmpty) {
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 10.0),
                    height: 60.0,
                    width: 300.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      title: Text(
                        schedule[index].title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.watch_later,
                              color: Colors.grey, size: 12.0),
                          SizedBox(width: 5.0),
                          Text(
                            TimeOfDay.fromDateTime(
                              schedule[index].date,
                            ).format(context),
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Icon(
                          ReminderIcon.getReminderIcon(schedule[index].type)),
                    ),
                  );
                },
                itemCount: schedule.length);
          } else {
            return EmptyContentWidget(
              title: AppLocalizations.of(context)
                  .translate("todosEmptyTopMsgDefaultTxt"),
              message: AppLocalizations.of(context)
                  .translate("todosEmptyBottomDefaultMsgTxt"),
            );
          }
        } else if (snapshot.hasError) {
          print("jjdfjf" + snapshot.error.toString());
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

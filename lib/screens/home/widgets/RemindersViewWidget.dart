import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/date_model.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/screens/calendarpage.dart';
import 'package:timeplan/screens/home/empty_content.dart';
import 'package:timeplan/screens/home/widgets/dateTile.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/shared/typeIcon.dart';

class RemindersViewWidget extends StatefulWidget {
  const RemindersViewWidget({
    Key key,
    @required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  _RemindersViewWidgetState createState() => _RemindersViewWidgetState(context);
}

class _RemindersViewWidgetState extends State<RemindersViewWidget> {
  final BuildContext context;
  _RemindersViewWidgetState(this.context);

  List<DateModel> dates;
  DateTime date;
  int todayDateIs;
  int _previousIndex;
  void _addData() {
    for (int i = 0; i < 7; i++) {
      String weekDay = DateFormat('EEEE').format(date);

      dates.add(
        DateModel(
          date: date.day.toString(),
          weekDay: weekDay.substring(0, 3),
        ),
      );
      date = date.add(Duration(days: 1));
    }
    date = date.subtract(Duration(days: 7));
    print("jdjjf" + date.toString());
  }

  @override
  void initState() {
    super.initState();
    // final firestoreDatabase =
    //     Provider.of<FirestoreDatabase>(context, listen: false);
    dates = new List<DateModel>();
    DateTime tempDate = DateTime.now();
    date = new DateTime(tempDate.year, tempDate.month, tempDate.day);
    todayDateIs = date.day;
    _previousIndex = 0;
    _addData();
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
          "Reminders",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        subtitle: Text("You have 5 events today",
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        trailing:   InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarView()));
            },
            child: Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.calendar_today),
            ),
          ),
         ),
      SizedBox(height: 10.0),
      Container(
        height: 60,
        margin: EdgeInsets.only(left: 8.0),
        child: ListView.builder(
            itemCount: dates.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (index > _previousIndex) {
                    setState(() {
                      date = date.add(Duration(days: index - _previousIndex));
                      _previousIndex = index;
                    });
                  } else if (index < _previousIndex) {
                    setState(() {
                      date =
                          date.subtract(Duration(days: _previousIndex - index));
                      _previousIndex = index;
                    });
                  }
                },
                child: DateTile(
                  weekDay: dates[index].weekDay,
                  date: dates[index].date,
                  isSelected: date.day.toString() == dates[index].date,
                ),
              );
            }),
      ),
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
                    height: 100.0,
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
                      trailing: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Icon(
                            ReminderIcon.getReminderIcon(schedule[index].type)),
                      ),
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
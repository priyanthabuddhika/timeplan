import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/date_model.dart';
import 'package:timeplan/models/schedule.dart';
import 'package:timeplan/screens/home/widgets/empty_content.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/shared/constants.dart';

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

  @override
  void initState() {
    super.initState();

    dates = new List<DateModel>();
    DateTime tempDate = DateTime.now();
    date = new DateTime(tempDate.year, tempDate.month, tempDate.day);
    todayDateIs = date.day;
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
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/fullschedulepage',
              );
            },
            child: Container(
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.list_rounded),
            ),
          )
        ]),
      ),
      kSizedBox,
      kSizedBox,
      Container(height: 200.0, child: _buildRemindersList()),
    ]);
  }

  Widget _buildRemindersList() {
    DateTime day = DateTime.now();
    String weekDay = DateFormat('EEEE').format(day);
    print(weekDay);
    final _firestoreDatabase =
        Provider.of<FirestoreDatabase>(widget.context, listen: false);
    return StreamBuilder(
      stream: _firestoreDatabase.schedulesForDay(day: weekDay),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Schedule> schedule = snapshot.data;
          if (schedule.isNotEmpty) {
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/schedulespage',
                          arguments: schedule[index]);
                    },
                    child: Container(
                      width: 300,
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      margin: EdgeInsets.only(
                          right: 10.0, bottom: 15.0, left: 10.0, top: 10.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.watch_later,
                                  color: Colors.grey, size: 12.0),
                              SizedBox(width: 5.0),
                              Text(
                                "${TimeOfDay.fromDateTime(schedule[index].startTime).format(context)} - ${TimeOfDay.fromDateTime(schedule[index].endTime).format(context)}",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12.0),
                              ),
                              Spacer(),
                              Icon(
                                schedule[index].icon,
                                color: kGradientColorOne,
                              ),
                            ],
                          ),
                          Text(
                            schedule[index].title,
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
                            schedule[index].description,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: schedule.length);
          } else {
            return EmptyContentWidget(
              assetSrc: "assets/icons/Add_files.svg",
              title: AppLocalizations.of(context)
                  .translate("todosEmptyTopMsgDefaultTxt"),
              message: AppLocalizations.of(context)
                  .translate("todosEmptyBottomDefaultMsgTxt"),
            );
          }
        } else if (snapshot.hasError) {
          print("jjdfjf" + snapshot.error.toString());
          return EmptyContentWidget(
            assetSrc: "assets/icons/Add_files.svg",
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeplan/models/schedule.dart';
import 'package:timeplan/screens/home/empty_content.dart';
import 'package:timeplan/screens/home/widgets/dateTile.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:timeplan/shared/typeIcon.dart';

class FullSchedulePage extends StatefulWidget {
  @override
  _FullSchedulePageState createState() => _FullSchedulePageState();
}

class _FullSchedulePageState extends State<FullSchedulePage>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  ScrollController _scrollController;

  DateTime currentDate;
  bool _initCompleted;

  List<String> _weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  String selectedDate;
  FirestoreDatabase _firestoreDatabase;
  @override
  void initState() {
    super.initState();
    DateTime day = DateTime.now();
    selectedDate = DateFormat('EEEE').format(day);

    _initCompleted = false;
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();

    Future.delayed(Duration(milliseconds: 900), () {
      _scrollController.animateTo(
        _scrollController.position.pixels +
            (100 * _weekdays.indexOf(selectedDate)),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initCompleted) {
      _firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: false);
      _initCompleted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        elevation: 0,
        backgroundColor: Color(0xFFF6F6F6),
        title: Text(
          "Daily Schedule",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
            onTap: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 10.0, top: 15.0, right: 10.0, bottom: 10.0),
          child: Column(children: <Widget>[
            Container(
              height: 60,
              child: ListView.builder(
                  itemCount: _weekdays.length,
                  shrinkWrap: true,
                  controller: _scrollController,
                  // padding: EdgeInsets.only(left: 20.0),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(left: 0.0),
                      child: InkWell(
                        onTap: () {
                          if (_weekdays.indexOf(selectedDate) < index) {
                            setState(() {
                              selectedDate = _weekdays[index];
                              _scrollController.animateTo(
                                _scrollController.position.pixels + 100,
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOut,
                              );
                            });
                          } else if (_weekdays.indexOf(selectedDate) > index) {
                            setState(() {
                              selectedDate = _weekdays[index];
                              _scrollController.animateTo(
                                _scrollController.position.pixels - 100,
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOut,
                              );
                            });
                          }
                        },
                        child: DateTile(
                          weekDay: "",
                          date: _weekdays[index].substring(0, 3),
                          isSelected: selectedDate == _weekdays[index],
                          textSize: 20.0,
                        ),
                      ),
                    );
                  }),
            ),
            kSizedBox,
            kSizedBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListTile(
                title: Text(
                  "$selectedDate Events",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                subtitle: Text(
                  "Your daily schedule",
                  style: TextStyle(color: Colors.grey),
                ),
                // style: TextStyle(color: Colors.grey, fontSize: 14)),
                trailing: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/schedulespage',
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ),
            SizedBox(height: 15.0),
            Container(
              height: 60,
              margin: EdgeInsets.only(left: 8.0),
              child: _buildRemiderList(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildRemiderList() {
    return StreamBuilder(
        stream: _firestoreDatabase.schedulesForDay(day: selectedDate),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Schedule> schedule = snapshot.data;
            if (schedule.isNotEmpty) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return TimelineTile(
                        alignment: TimelineAlign.manual,
                        lineXY: 0.2,
                        isFirst: index == 0,
                        isLast: !(index < schedule.length - 1),
                        afterLineStyle: LineStyle(thickness: 1),
                        beforeLineStyle: LineStyle(thickness: 1),
                        indicatorStyle: IndicatorStyle(
                          width: 15,
                          color: kGradientColorTwo,
                          indicatorXY: 0.3,
                          iconStyle: IconStyle(
                              color: Colors.white,
                              iconData: index == 0 ? Icons.add : Icons.circle,
                              fontSize: 10.0),
                        ),
                        startChild: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                TimeOfDay.fromDateTime(
                                        schedule[index].startTime)
                                    .format(context),
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                TimeOfDay.fromDateTime(schedule[index].endTime)
                                    .format(context),
                              ),
                            ],
                          ),
                        ),
                        endChild: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed('/reminderspage',
                                arguments: schedule[index]);
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                right: 10.0,
                                bottom: 15.0,
                                left: 10.0,
                                top: 10.0),
                            padding: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                bottom: 15.0,
                                top: 10.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.watch_later,
                                        color: Colors.grey, size: 12.0),
                                    SizedBox(width: 5.0),
                                    Text(
                                      TimeOfDay.fromDateTime(
                                        schedule[index].startTime,
                                      ).format(context),
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    Icon(
                                      ReminderIcon.getReminderIcon(
                                          schedule[index].type),
                                      color: kGradientColorOne,
                                    ),
                                  ],
                                ),
                                Text(
                                  schedule[index].title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                kSizedBox,
                                Text(
                                  "View",
                                  style: TextStyle(
                                      fontSize: 10.0, color: Colors.grey),
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
                        ),
                      );
                    },
                    itemCount: schedule.length),
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
            print("jjdfjf" + snapshot.error.toString());
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

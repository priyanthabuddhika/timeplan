import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/screens/home/widgets/empty_content.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeline_tile/timeline_tile.dart';

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  AnimationController _animationController;
  CalendarController _calendarController;

  FirestoreDatabase _firestoreDatabase;

  DateTime currentDate;
  DateTime lastDate;
  DateTime _selectedDate;
  bool _initCompleted;

  @override
  void initState() {
    super.initState();

    _initCompleted = false;
    currentDate = DateTime.now();
    lastDate = new DateTime(currentDate.year, currentDate.month + 1, 0);
    _selectedDate = currentDate;
    _events = {};
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initCompleted) {
      _firestoreDatabase =
          Provider.of<FirestoreDatabase>(context, listen: true);
      _initCompleted = true;
    }
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    
    setState(() {
      _selectedDate = day;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    setState(() {
      _events = {};
      currentDate = _calendarController.focusedDay;
      currentDate = currentDate.toLocal();
      lastDate = new DateTime(currentDate.year, currentDate.month + 1, 0);
      // _selectedDate = first;
    });
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kPrimaryBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          DateFormat.yMMMM("en_US").format(
              _calendarController.focusedDay != null
                  ? _calendarController.focusedDay
                  : currentDate),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
          stream: _firestoreDatabase.remindersForDay(
              day: currentDate, datePlus: lastDate),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Reminder> schedule = snapshot.data;

              if (schedule.isNotEmpty) {
                for (int i = 0; i < schedule.length; i++) {
                  if (_events.isEmpty) {
                    _events[schedule[i].date] = [schedule[i].id];
                  } else {
                    if (_events[schedule[i].date] == null) {
                      _events[schedule[i].date] = [schedule[i].id];
                    } else {
                      _events[schedule[i].date].add(schedule[i].id);
                    }
                  }
                }

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildTableCalendar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListTile(
                        title: Text(
                          "Reminders",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                        subtitle: Text(
                          "You have ${schedule.length} upcoming events",
                          style: TextStyle(color: Colors.grey),
                        ),
                        // style: TextStyle(color: Colors.grey, fontSize: 14)),
                        trailing: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/reminderspage',
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
                    Expanded(child: _buildRemiderList(schedule)),
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildTableCalendar(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ListTile(
                        title: Text(
                          "Reminders",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        ),
                        subtitle: Text(
                          "You have ${schedule.length} upcoming events",
                          style: TextStyle(color: Colors.grey),
                        ),
                        // style: TextStyle(color: Colors.grey, fontSize: 14)),
                        trailing: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/reminderspage',
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
                    SizedBox(
                      height: size.height * 0.3,
                      child: EmptyContentWidget(
                        assetSrc: "assets/icons/Add_files.svg",
                        title: AppLocalizations.of(context)
                            .translate("todosEmptyTopMsgDefaultTxt"),
                        message: AppLocalizations.of(context)
                            .translate("todosEmptyBottomDefaultMsgTxt"),
                      ),
                    ),
                  ],
                );
              }
            } else if (snapshot.hasError) {
              
              return EmptyContentWidget(
                assetSrc: "assets/icons/Add_files.svg",
                title: AppLocalizations.of(context)
                    .translate("todosEmptyTopMsgDefaultTxt"),
                message: AppLocalizations.of(context)
                    .translate("todosEmptyBottomDefaultMsgTxt"),
              );
            }
            return _buildTableCalendar();
          }),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      child: TableCalendar(
        availableCalendarFormats: const {CalendarFormat.month: "Month"},
        calendarController: _calendarController,
        // events: _events,
        holidays: _events,
        rowHeight: 35.0,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          contentPadding:
              EdgeInsets.only(left: 5.0, bottom: 0, top: 0, right: 5.0),
          selectedColor: kGradientColorTwo,
          todayColor: Colors.deepOrange[200],
          outsideDaysVisible: true,
          weekdayStyle: TextStyle(),
          weekendStyle: TextStyle(color: Colors.black),
          holidayStyle: TextStyle(color: Colors.purple),
        ),

        headerVisible: false,
        onDaySelected: _onDaySelected,
        onVisibleDaysChanged: _onVisibleDaysChanged,
        onCalendarCreated: _onCalendarCreated,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.grey),
          weekendStyle: TextStyle(color: Colors.grey),
          dowTextBuilder: (date, locale) =>
              DateFormat('EEEE').format(date).substring(0, 1),
        ),
      ),
    );
  }

  Widget _buildRemiderList(List<Reminder> schedule) {
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
                      schedule[index].date.day.toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      DateFormat('EEEE')
                          .format(schedule[index].date)
                          .substring(0, 3),
                    ),
                  ],
                ),
              ),
              endChild: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/reminderspage', arguments: schedule[index]);
                },
                child: Container(
                  margin: EdgeInsets.only(
                      right: 10.0, bottom: 15.0, left: 10.0, top: 10.0),
                  padding: EdgeInsets.only(
                      left: 15.0, right: 15.0, bottom: 15.0, top: 10.0),
                  decoration: BoxDecoration(
                      color: schedule[index].date.day == _selectedDate.day
                          ? kPrimaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.watch_later,
                              color: Colors.grey, size: 12.0),
                          SizedBox(width: 5.0),
                          Text(
                            TimeOfDay.fromDateTime(
                              schedule[index].date,
                            ).format(context),
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 10.0, color: Colors.grey),
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
  }
}

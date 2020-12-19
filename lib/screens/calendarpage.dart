import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeplan/models/remider.dart';
import 'package:timeplan/screens/home/empty_content.dart';
import 'package:timeplan/services/app_localizations.dart';
import 'package:timeplan/services/firestore_database.dart';
import 'package:timeplan/shared/constants.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:timeplan/shared/typeIcon.dart';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): ['New Year\'s Day'],
  DateTime(2020, 1, 6): ['Epiphany'],
  DateTime(2020, 2, 14): ['Valentine\'s Day'],
  DateTime(2020, 4, 21): ['Easter Sunday'],
  DateTime(2020, 4, 22): ['Easter Monday'],
};

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;

  DateTime currentDate;

  @override
  void initState() {
    super.initState();
    final _selectedDay = DateTime.now();
    currentDate = _selectedDay;
    _events = {
      _selectedDay.subtract(Duration(days: 30)): [
        'Event A0',
        'Event B0',
        'Event C0'
      ],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): [
        'Event A2',
        'Event B2',
        'Event C2',
        'Event D2'
      ],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): [
        'Event A4',
        'Event B4',
        'Event C4'
      ],
      _selectedDay.subtract(Duration(days: 4)): [
        'Event A5',
        'Event B5',
        'Event C5'
      ],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
      _selectedDay.add(Duration(days: 1)): [
        'Event A8',
        'Event B8',
        'Event C8',
        'Event D8'
      ],
      _selectedDay.add(Duration(days: 3)):
          Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): [
        'Event A10',
        'Event B10',
        'Event C10'
      ],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): [
        'Event A12',
        'Event B12',
        'Event C12',
        'Event D12'
      ],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): [
        'Event A14',
        'Event B14',
        'Event C14'
      ],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
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

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    setState(() {
      print("aaddo" + first.toString());
      currentDate = first;
    });
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: kPrimaryBackgroundColor,
        centerTitle: true,
        title: Text(
          DateFormat.yMMMM("en_US").format(
              _calendarController.focusedDay != null
                  ? _calendarController.focusedDay
                  : currentDate),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          // _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          const SizedBox(height: 8.0),
          Expanded(child: _buildRemiderList()),
          // Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      child: TableCalendar(
        availableCalendarFormats: const {CalendarFormat.month: "Month"},
        calendarController: _calendarController,
        events: _events,
        holidays: _holidays,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
            selectedColor: Colors.deepOrange[400],
            todayColor: Colors.deepOrange[200],
            markersColor: Colors.brown[700],
            outsideDaysVisible: false,
            weekdayStyle: TextStyle()),
        headerVisible: false,
        headerStyle: HeaderStyle(
          centerHeaderTitle: true,
          formatButtonTextStyle:
              TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
          formatButtonDecoration: BoxDecoration(
            color: Colors.deepOrange[400],
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        onDaySelected: _onDaySelected,
        onVisibleDaysChanged: _onVisibleDaysChanged,
        onCalendarCreated: _onCalendarCreated,
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildRemiderList() {
    final _firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);
    DateTime firstDate = currentDate.subtract(Duration(days: currentDate.day));
    DateTime lastDate = currentDate.month != 12
        ? new DateTime(currentDate.year, currentDate.month + 1, 1)
        : new DateTime(currentDate.year + 1, 1);
    return StreamBuilder(
      stream: _firestoreDatabase.remindersForDay(
          day: firstDate, datePlus: lastDate),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Reminder> schedule = snapshot.data;
          if (schedule.isNotEmpty) {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.2,
                    isFirst: index == 0,
                    isLast: !(index < schedule.length - 1),
                    afterLineStyle: LineStyle(thickness: 2),
                    beforeLineStyle: LineStyle(thickness: 2),
                    indicatorStyle: IndicatorStyle(
                      width: 20,
                      color: Colors.purple,
                      indicatorXY: 0.3,
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: index == 0
                            ? Icons.crop_square_outlined
                            : Icons.circle,
                      ),
                    ),
                    startChild: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          SizedBox(height: 10.0,),
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
                    endChild: Container(
                      margin: EdgeInsets.only(right: 10.0, bottom: 10.0,left: 10.0),
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
                          child: Icon(ReminderIcon.getReminderIcon(
                              schedule[index].type)),
                        ),
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

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }
}

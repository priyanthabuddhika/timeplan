import 'package:flutter/material.dart';
import 'package:timeplan/shared/constants.dart';

class DateTile extends StatelessWidget {

  String weekDay;
  String date;
  bool isSelected;
  DateTile({this.weekDay, this.date, this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 25),
      padding: EdgeInsets.symmetric(horizontal: 20, ),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryColor : Colors.white,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(date, style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600
          ),),
          SizedBox(height: 10,),
          Text(weekDay, style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600
          ),)
        ],
      ),
    );
  }
}

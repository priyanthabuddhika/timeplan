import 'package:flutter/material.dart';
import 'package:timeplan/shared/constants.dart';

class DateTile extends StatelessWidget {
  String weekDay;
  String date;
  bool isSelected;
  double textSize;
  DateTile({this.weekDay, this.date, this.isSelected, this.textSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 25),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [kGradientColorOne, kGradientColorTwo])
              : LinearGradient(colors: [Colors.white, Colors.white]),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            date,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: textSize ?? 25.0),
          ),
          SizedBox(
            height: textSize != null ? 0 : 3,
          ),
          Text(
            weekDay,
            style: TextStyle(
              fontSize: textSize != null ? 0.1 : 12,
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}

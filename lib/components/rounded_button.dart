import 'package:flutter/material.dart';
import 'package:timeplan/shared/constants.dart';
// rounded button used in authentication pages
class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  const RoundedButton({
    Key key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kButtonBorderRadius),
        gradient: LinearGradient(
          colors: [kGradientColorOne, kGradientColorTwo],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),

          onPressed: press,
          child: Text(
            text,
            style: TextStyle(fontSize: 15.0 , color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

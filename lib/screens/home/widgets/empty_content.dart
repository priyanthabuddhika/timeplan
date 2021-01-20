import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyContentWidget extends StatelessWidget {
  final String title;
  final String message;
  final String assetSrc;

  EmptyContentWidget({Key key, this.title, this.message, this.assetSrc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          assetSrc != null
              ? Expanded(
                  child: SvgPicture.asset(
                    assetSrc,
                    fit: BoxFit.contain,
                  ),
                )
              : SizedBox(),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(message),
        ],
      ),
    );
  }
}

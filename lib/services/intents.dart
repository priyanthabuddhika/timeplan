import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:android_intent/flag.dart';
import 'package:flutter/material.dart';

/// Holds the different intent widgets.
class IntentService extends StatelessWidget {
  void _createAlarm() {
    final AndroidIntent intent = const AndroidIntent(
      action: 'android.intent.action.SET_ALARM',
      arguments: <String, dynamic>{
        'android.intent.extra.alarm.DAYS': <int>[2, 3, 4, 5, 6],
        'android.intent.extra.alarm.HOUR': 21,
        'android.intent.extra.alarm.MINUTES': 30,
        'android.intent.extra.alarm.SKIP_UI': true,
        'android.intent.extra.alarm.MESSAGE': 'Create a Flutter app',
      },
    );
    intent.launch();
  }

  void _openExplicitIntentsView(BuildContext context) {
    Navigator.of(context).pushNamed(ExplicitIntentsWidget.routeName);
  }


  @override
  Widget build(BuildContext context) {
    Widget body;
    if (Platform.isAndroid) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: const Text(
                  'Tap here to set an alarm\non weekdays at 9:30pm.'),
              onPressed: _createAlarm,
            ),
            RaisedButton(
                child: const Text('Tap here to test explicit intents.'),
                onPressed: () => _openExplicitIntentsView(context)),
          ],
        ),
      );
    } else {
      body = const Text('This plugin only works with Android');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(child: body),
    );
  }
}

/// Launches intents to specific Android activities.
class ExplicitIntentsWidget extends StatelessWidget {
  const ExplicitIntentsWidget(); // ignore: public_member_api_docs

  // ignore: public_member_api_docs
  static const String routeName = "/explicitIntents";

  void _openGoogleMapsStreetView() {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.streetview:cbll=46.414382,10.013988'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _displayMapInGoogleMaps({int zoomLevel = 12}) {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('geo:37.7749,-122.4194?z=$zoomLevel'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _launchTurnByTurnNavigationInGoogleMaps() {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(
            'google.navigation:q=Taronga+Zoo,+Sydney+Australia&avoid=tf'),
        package: 'com.google.android.apps.maps');
    intent.launch();
  }

  void _openLinkInGoogleChrome() {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.io'),
        package: 'com.android.chrome');
    intent.launch();
  }

  void _startActivityInNewTask() {
    final AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull('https://flutter.io'),
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  void _testExplicitIntentFallback() {
    final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('https://flutter.io'),
        package: 'com.android.chrome.implicit.fallback');
    intent.launch();
  }

  void _openLocationSettingsConfiguration() {
    final AndroidIntent intent = const AndroidIntent(
      action: 'action_location_source_settings',
    );
    intent.launch();
  }

  void _openApplicationDetails() {
    final AndroidIntent intent = const AndroidIntent(
      action: 'action_application_details_settings',
      data: 'package:io.flutter.plugins.androidintentexample',
    );
    intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test explicit intents'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                child: const Text(
                    'Tap here to display panorama\nimagery in Google Street View.'),
                onPressed: _openGoogleMapsStreetView,
              ),
              RaisedButton(
                child: const Text('Tap here to display\na map in Google Maps.'),
                onPressed: _displayMapInGoogleMaps,
              ),
              RaisedButton(
                child: const Text(
                    'Tap here to launch turn-by-turn\nnavigation in Google Maps.'),
                onPressed: _launchTurnByTurnNavigationInGoogleMaps,
              ),
              RaisedButton(
                child: const Text('Tap here to open link in Google Chrome.'),
                onPressed: _openLinkInGoogleChrome,
              ),
              RaisedButton(
                child: const Text('Tap here to start activity in new task.'),
                onPressed: _startActivityInNewTask,
              ),
              RaisedButton(
                child: const Text(
                    'Tap here to test explicit intent fallback to implicit.'),
                onPressed: _testExplicitIntentFallback,
              ),
              RaisedButton(
                child: const Text(
                  'Tap here to open Location Settings Configuration',
                ),
                onPressed: _openLocationSettingsConfiguration,
              ),
              RaisedButton(
                child: const Text(
                  'Tap here to open Application Details',
                ),
                onPressed: _openApplicationDetails,
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:teavault/screens/stash/brew_profiles_screen.dart';
import 'package:teavault/screens/stash/stash.dart';
import 'package:teavault/tea_session_controller.dart';
import 'package:vibration/vibration.dart';

void selectTeaFromStash(BuildContext context) {
//  //TODO: Implement select pot
//  Navigator.push(
//      context,
//      MaterialPageRoute(
//          builder: (context) => Scaffold(
//            appBar: AppBar(title: Text("Select a Tea")),
//            body: StashView(true),
//          )));

  final selectTeaRoute = MaterialPageRoute(
      builder: (context) => Scaffold(
            appBar: AppBar(title: Text("Select a Tea")),
            body: StashView(suppressTileMenu: true),
          ));

  Navigator.push(context, selectTeaRoute);

  selectTeaRoute.popped.then((_) {
    final teaSessionController = Provider.of<TeaSessionController>(context, listen: false);
    if (teaSessionController.currentTea != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BrewProfilesScreen(
                    teaSessionController.currentTea,
                    suppressTileMenu: true,
                  )));
    }
  });
}

Function haptic(Function fn) => () {
  Vibration.vibrate(duration: 10, intensities: [127]);
  fn();
};
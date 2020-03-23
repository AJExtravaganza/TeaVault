import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/brewing_vessel.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/screens/stash/brew_profiles_screen.dart';
import 'package:teavault/screens/stash/stash.dart';
import 'package:teavault/screens/teasessions/steep_timer.dart';
import 'package:teavault/tea_session_controller.dart';


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


import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:teavault/screens/teasessions/steep_timer.dart';
import 'package:teavault/tea_session_controller.dart';

import 'brew_info.dart';
import 'helper_functions.dart';

class TeaSessionView extends Consumer<TeaSessionController> {
  TeaSessionView()
      : super(builder: (context, controller, child) {
          final orientation = MediaQuery.of(context).orientation;
          if (orientation == Orientation.portrait) {
            return PortraitSessionsView(controller);
          } else {
            return LandscapeSessionsView(controller);
          }
        });
}

class PortraitSessionsView extends StatelessWidget {
  final TeaSessionController controller;

  PortraitSessionsView(this.controller);

  @override
  Widget build(BuildContext context) {
    final bool displaySteepTimer = controller.currentTea != null && controller.currentBrewProfile != null;

    if (controller.currentTea == null) {
      return Column(
        children: <Widget>[
          Expanded(flex: 3, child: InitialTeaSelectButton()),
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.grey,
            ),
          )
        ],
      );
    } else {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Expanded(
          flex: 2,
          child: BrewInfo(controller.currentTea, controller.currentBrewProfile, controller.currentBrewingVessel),
        ),
        Expanded(
          flex: 4,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(),
              )
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: displaySteepTimer ? SteepTimer(controller) : Container(),
        )
      ]);
    }
  }
}

class LandscapeSessionsView extends StatelessWidget {
  final TeaSessionController controller;

  LandscapeSessionsView(this.controller);

  @override
  Widget build(BuildContext context) {
    final bool displaySteepTimer = controller.currentTea != null && controller.currentBrewProfile != null;

    if (controller.currentTea == null) {
      return Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: InitialTeaSelectButton(),
          ),
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.grey,
            ),
          )
        ],
      );
    } else {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Expanded(
          flex: 3,
          child: BrewInfo(controller.currentTea, controller.currentBrewProfile, controller.currentBrewingVessel),
        ),
        Expanded(
          flex: 3,
          child: displaySteepTimer ? SteepTimer(controller) : Container(),
        )
      ]);
    }
  }
}

class InitialTeaSelectButton extends StatelessWidget {
  final padding = {
    Orientation.portrait: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
    Orientation.landscape: EdgeInsets.symmetric(vertical: 10, horizontal: 100)
  };

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Container(
      padding: padding[orientation],
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
          side: BorderSide(color: Colors.black38),
        ),
        color: Colors.white70,
        onPressed: () {
          onPressDefaultVibrate();
          selectTeaFromStash(context);
        },
        child: Center(
            child: Column(children: <Widget>[
          Expanded(
            flex: 7,
            child: Align(
              child: Text(
                'Welcome to TeaVault!',
                style: TextStyle(fontSize: 24),
              ),
              alignment: Alignment.bottomCenter,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text('  Select a tea to get started...'),
          )
        ])),
      ),
    );
  }
}

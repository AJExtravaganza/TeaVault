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
          child: BrewProfileInfo(controller.currentTea, controller.currentBrewProfile, controller.currentBrewingVessel),
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
          child: BrewProfileInfo(controller.currentTea, controller.currentBrewProfile, controller.currentBrewingVessel),
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

class BrewProfileInfo extends StatelessWidget {
  final Tea tea;
  final BrewProfile brewProfile;
  final BrewingVessel brewingVessel;

  BrewProfileInfo(this.tea, this.brewProfile, this.brewingVessel);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Container(),
        ),
        Expanded(flex: 6, child: TeaNameRow(this.tea)),
        Expanded(
            flex: 6,
            child: Column(
              children: [
                BrewingParametersRow(this.brewProfile, this.brewingVessel),
                BrewProfileNameRow(this.brewProfile)
              ],
            )),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}

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

class TeaNameRow extends StatelessWidget {
  final Tea tea;

  TeaNameRow(this.tea);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        selectTeaFromStash(context);
      },
      child: Row(
        children: <Widget>[
          Expanded(
              child: Center(
                  child: Text(
            this.tea.asString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30),
          )))
        ],
      ),
    );
  }
}

class BrewProfileNameRow extends StatelessWidget {
  final BrewProfile brewProfile;

  BrewProfileNameRow(this.brewProfile);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
          child: Center(
        child: Text('Brew Profile: ${brewProfile == BrewProfile.getDefault() ? "Default" : brewProfile.name}'),
      ))
    ]);
  }
}

class BrewingParametersRow extends StatelessWidget {
  final BrewProfile brewProfile;
  final BrewingVessel brewingVessel;

  BrewingParametersRow(this.brewProfile, this.brewingVessel);

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Expanded(
        flex: 10,
        child: Container(),
      ),
      Expanded(
        flex: 40,
        child: BrewingParameterRowElement(
            FontAwesomeIcons.leaf, '${brewProfile.getDose(brewingVessel).toStringAsFixed(1)}g'),
      ),
      Expanded(
        flex: 10,
        child: Container(),
      ),
      Expanded(
          flex: 42, child: BrewingParameterRowElement(FontAwesomeIcons.balanceScale, '1:${brewProfile.nominalRatio}')),
      Expanded(
        flex: 8,
        child: Container(),
      ),
      Expanded(
        flex: 40,
        child: BrewingParameterRowElement(FontAwesomeIcons.tint, '${brewingVessel.volumeMilliliters}ml'),
      ),
      Expanded(
        flex: 10,
        child: Container(),
      ),
      Expanded(
        flex: 40,
        child: BrewingParameterRowElement(FontAwesomeIcons.temperatureHigh, '${brewProfile.brewTemperatureCelsius}°C'),
      ),
      Expanded(
        flex: 10,
        child: Container(),
      ),
    ]);
  }
}

class BrewingParameterRowElement extends StatelessWidget {
  final IconData icon;
  final String valueText;

  BrewingParameterRowElement(this.icon, this.valueText);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        FaIcon(this.icon),
        Text(
          ' ' + this.valueText,
          style: TextStyle(fontSize: 18),
        )
      ],
    );
  }
}

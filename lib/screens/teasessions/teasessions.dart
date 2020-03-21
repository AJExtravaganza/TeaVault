import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/brewing_vessel.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/screens/stash/brew_profiles_screen.dart';
import 'package:teavault/screens/stash/stash.dart';
import 'package:teavault/screens/teasessions/steep_timer.dart';
import 'package:teavault/tea_session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SessionsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SessionsView();
}

class _SessionsView extends State<SessionsView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeaSessionController>(
        builder: (context, teaSessionController, child) => OrientationBuilder(
            builder: (context, orientation) => orientation == Orientation.portrait
                ? _portraitSessionsView(context)
                : _landscapeSessionsView(context)));
  }

  Widget _portraitSessionsView(BuildContext context) {
    final teaSessionController = Provider.of<TeaSessionController>(context, listen: false);
    final bool displaySteepTimer = teaSessionController.currentTea != null && teaSessionController.brewProfile != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Expanded(
        flex: 2,
        child: BrewProfileInfo(),
      ),
      Expanded(
        flex: 4,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(color: Colors.grey, child: Text('EvaluationAreaStub')),
            )
          ],
        ),
      ),
      Expanded(
        flex: 3,
        child: displaySteepTimer ? SteepTimer() : Container(),
      )
    ]);
  }

  Widget _landscapeSessionsView(BuildContext context) {
    final teaSessionController = Provider.of<TeaSessionController>(context, listen: false);
    final bool displaySteepTimer = teaSessionController.currentTea != null && teaSessionController.brewProfile != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Expanded(
        flex: 3,
        child: BrewProfileInfo(),
      ),
      Expanded(
        flex: 3,
        child: displaySteepTimer ? SteepTimer() : Container(),
      )
    ]);
  }
}

class BrewProfileInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Tea currentTea = Provider.of<TeaSessionController>(context).currentTea;
    if (currentTea == null) {
      return Material(
          borderRadius: (BorderRadius.only(bottomLeft: Radius.circular(40.0), bottomRight: Radius.circular(40.0))),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              selectTeaFromStash(context);
            },
            child: Center(
                child: Column(children: <Widget>[
                  Text(
                    '\n\nWelcome to TeaVault!',
                    style: TextStyle(fontSize: 24),
              ),
              Text('  Select a tea to get started...')
            ])),
          ));
    } else {
      return Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(),
          ),
          Expanded(flex: 6, child: TeaNameRow()),
          Expanded(
              flex: 6,
              child: Column(
                children: [BrewingParametersRow(), BrewProfileNameRow()],
              )),
//          Expanded(flex: 3, child: BrewingParametersRow()),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      );
    }
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BrewProfilesScreen(
                  Provider.of<TeaSessionController>(context).currentTea,
                  suppressTileMenu: true,
                )));
  });
}

class TeaNameRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Tea currentTea = Provider.of<TeaSessionController>(context).currentTea;
    return InkWell(
      onTap: () {
        selectTeaFromStash(context);
      },
      child: Row(
        children: <Widget>[
          Expanded(
              child: Center(
                  child: Text(
            currentTea.asString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30),
          )))
        ],
      ),
    );
  }
}

class BrewProfileNameRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeaSessionController>(
        builder: (context, activeTeaSession, child) => Row(children: <Widget>[
              Expanded(
                  child: Center(
                    child: Text('Brew Profile: ${activeTeaSession.brewProfile.name}'),
              ))
            ]));
  }
}

class BrewingParametersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BrewingVessel currentBrewingVessel = Provider
        .of<TeaSessionController>(context)
        .brewingVessel;
    BrewProfile currentBrewProfile = Provider
        .of<TeaSessionController>(context)
        .brewProfile;
    return Row(children: <Widget>[
      Expanded(
        flex: 10,
        child: Container(),
      ),
      Expanded(
        flex: 40,
        child: BrewingParameterRowElement(
            FontAwesomeIcons.leaf, '${currentBrewProfile.getDose(currentBrewingVessel).toStringAsFixed(1)}g'),
      ),
      Expanded(
        flex: 10,
        child: Container(),
      ),
      Expanded(
          flex: 42,
          child: BrewingParameterRowElement(FontAwesomeIcons.balanceScale, '1:${currentBrewProfile.nominalRatio}')),
      Expanded(
        flex: 8,
        child: Container(),
      ),
      Expanded(
        flex: 40,
        child: BrewingParameterRowElement(FontAwesomeIcons.tint, '${currentBrewingVessel.volumeMilliliters}ml'),
      ),
      Expanded(
        flex: 10,
        child: Container(),
      ),
      Expanded(
        flex: 40,
        child: BrewingParameterRowElement(
            FontAwesomeIcons.temperatureHigh, '${currentBrewProfile.brewTemperatureCelsius}°C'),
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

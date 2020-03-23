import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/brewing_vessel.dart';
import 'package:teavault/models/tea.dart';

import 'helper_functions.dart';

class BrewInfo extends StatelessWidget {
  final Tea tea;
  final BrewProfile brewProfile;
  final BrewingVessel brewingVessel;

  BrewInfo(this.tea, this.brewProfile, this.brewingVessel);

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

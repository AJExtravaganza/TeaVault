import 'package:flutter/material.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/tea.dart';

import 'brew_profile_form.dart';

class EditBrewProfileScreen extends StatelessWidget {
  final Tea _tea;
  final BrewProfile _brewProfile;

  EditBrewProfileScreen(this._tea, this._brewProfile);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Existing Brew Profile'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 0,
            child: Container(),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: BrewProfileEditForm(this._tea, this._brewProfile),
            ),
          ),
        ],
      ),
    );
  }
}

class BrewProfileEditForm extends BrewProfileForm {
  final Tea _tea;
  final BrewProfile _brewProfile;

  BrewProfileEditForm(this._tea, this._brewProfile);

  @override
  BrewProfileFormState createState() => new _BrewProfileEditFormState(_tea, _brewProfile);
}

class _BrewProfileEditFormState extends BrewProfileFormState {
  bool editExisting = true;

  _BrewProfileEditFormState(Tea tea, BrewProfile brewProfile)
      : super(tea, brewProfile.name, brewProfile.nominalRatio, brewProfile.brewTemperatureCelsius,
            brewProfile.steepTimings);
}

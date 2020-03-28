import 'package:flutter/material.dart';
import 'package:teavault/models/tea.dart';

import 'brew_profile_form.dart';

class AddNewBrewProfileScreen extends StatelessWidget {
  final Tea _tea;

  AddNewBrewProfileScreen(this._tea);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Brew Profile'), iconTheme: IconThemeData(color: Colors.white)),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: MediaQuery.of(context).orientation == Orientation.portrait ? 4 : 1,
            child: Container(),
          ),
          Expanded(
            flex: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: BrewProfileAddForm(this._tea),
            ),
          ),
        ],
      ),
    );
  }
}

class BrewProfileAddForm extends BrewProfileForm {
  final Tea _tea;

  BrewProfileAddForm(this._tea);

  @override
  BrewProfileFormState createState() => new BrewProfileAddFormState(_tea);
}

class BrewProfileAddFormState extends BrewProfileFormState {
  bool editExisting = false;

  BrewProfileAddFormState(Tea tea) : super(tea);
}

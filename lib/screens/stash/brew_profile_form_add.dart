import 'package:flutter/material.dart';
import 'package:teavault/models/tea.dart';

import 'brew_profile_form.dart';

class AddNewBrewProfileScreen extends StatelessWidget {
  final Tea _tea;

  AddNewBrewProfileScreen(this._tea);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Brew Profile'),
      ),
      body: BrewProfileAddForm(this._tea),
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

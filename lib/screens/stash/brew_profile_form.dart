import 'dart:math';

import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

abstract class BrewProfileForm extends StatefulWidget {}

class BrewProfileFormState extends State<BrewProfileForm> {
  final _formKey = GlobalKey<FormState>();
  bool editExisting;

  final Tea _tea;

  String _name;
  int _nominalRatio;
  int _brewTemperatureCelsius;
  List<int> _steepTimings = [];

  BrewProfileFormState(this._tea,
      [this._name = '', this._nominalRatio = 15, this._brewTemperatureCelsius = 100, this._steepTimings]);

  //  Necessary for TextFormField select-all-on-focus
  String _nominalRatioFieldInitialValue;
  TextEditingController _nominalRatioFieldController;
  FocusNode _nominalRatioFieldFocusNode;

  String _brewTemperatureFieldInitialValue;
  TextEditingController _brewTemperatureFieldController;
  FocusNode _brewTemperatureFieldFocusNode;

  @override
  initState() {
    super.initState();

    //  This stuff all implements TextFormField select-all-on-focus
    this._nominalRatioFieldInitialValue = this._nominalRatio.toString();
    this._nominalRatioFieldController = TextEditingController(text: _nominalRatioFieldInitialValue);
    _nominalRatioFieldFocusNode = FocusNode();

    this._brewTemperatureFieldInitialValue = this._brewTemperatureCelsius.toString();
    this._brewTemperatureFieldController = TextEditingController(text: _brewTemperatureFieldInitialValue);
    _brewTemperatureFieldFocusNode = FocusNode();

    _nominalRatioFieldFocusNode.addListener(() {
      if (_nominalRatioFieldFocusNode.hasFocus) {
        _nominalRatioFieldController.selection =
            TextSelection(baseOffset: 0, extentOffset: _nominalRatioFieldInitialValue.length);
      }
    });

    _brewTemperatureFieldFocusNode.addListener(() {
      if (_brewTemperatureFieldFocusNode.hasFocus) {
        _brewTemperatureFieldController.selection =
            TextSelection(baseOffset: 0, extentOffset: _brewTemperatureFieldInitialValue.length);
      }
    });
  }

  @override
  dispose() {
    _nominalRatioFieldFocusNode.dispose();
    _brewTemperatureFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: new ListView(children: <Widget>[
        TextFormField(
            enabled: !this.editExisting,
            decoration: InputDecoration(labelText: 'Enter Profile Name', hintText: ''),
            initialValue: this._name,
            validator: (value) {
              value = value.trim();
              if (value.isEmpty) {
                return 'Please enter a name for this profile';
              } else if (!this.editExisting &&
                  _tea.brewProfiles
                      .where((brewProfile) => brewProfile.name == value)
                      .length > 0) {
                return 'A brew profile named $value already exists for this tea';
              }

              return null;
            },
            onSaved: (value) {
              setState(() {
                value = value.trim();
                _name = value.trim();
              });
            },
            keyboardType: TextInputType.text),
        TextFormField(
            decoration: InputDecoration(labelText: 'Enter Ratio', hintText: 'Enter x to represent 1:x leaf:water'),
            focusNode: _nominalRatioFieldFocusNode,
            controller: _nominalRatioFieldController,
            validator: (value) {
              if (int.tryParse(value) == null || int.parse(value) < 5 || int.parse(value) > 200) {
                return 'Please enter a valid value (5-200)';
              }

              return null;
            },
            onSaved: (value) {
              setState(() {
                _nominalRatio = int.parse(value);
              });
            },
            keyboardType: TextInputType.number),
        TextFormField(
            decoration: InputDecoration(labelText: 'Enter Brew Temperature (°C)', hintText: ''),
            focusNode: _brewTemperatureFieldFocusNode,
            controller: _brewTemperatureFieldController,
            validator: (value) {
              if (int.tryParse(value) == null || int.parse(value) < 1 || int.parse(value) > 100) {
                return 'Please enter a valid value (1-100)';
              }

              return null;
            },
            onSaved: (value) {
              setState(() {
                _brewTemperatureCelsius = int.parse(value);
              });
            },
            keyboardType: TextInputType.number),
        TextFormField(
            decoration: InputDecoration(
                labelText: 'Enter Steep Timings',
                hintText: 'Enter in seconds, comma-separated.  First value is rinse.'),
            initialValue: _steepTimings != null && _steepTimings.length > 0 ? _steepTimings.join(',') : '',
            validator: (value) {
              try {
                value.replaceAll(' ', '').split(',').where((str) => str != '').map((str) => int.parse(str));
              } on FormatException catch (err) {
                return 'Please enter a valid set of comma-separated integers.';
              }

              return null;
            },
            onSaved: (value) {
              setState(() {
                final timingsList = value
                    .trim()
                    .length > 0
                    ? value.replaceAll(' ', '').split(',').map((str) => max(int.parse(str), 0)).toList()
                    : [
                  0,
                ];
                _steepTimings = timingsList;
              });
            },
            keyboardType: TextInputType.number),
        RaisedButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text('Save Brew Profile'),
            onPressed: () async {
              await brewProfileFormSubmit(Provider.of<TeaCollectionModel>(context, listen: false),
                  edit: this.editExisting);
            })
      ]),
    );
  }

  void brewProfileFormSubmit(TeaCollectionModel teaCollection, {edit = false}) async {
    bool defaultToFavorite = !_tea.hasCustomBrewProfiles || _tea.defaultBrewProfile.name == _name;
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).unfocus(); //Dismiss the keyboard
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Adding new brew profile...')));
      await teaCollection.updateBrewProfile(
          BrewProfile(_name, _nominalRatio, _brewTemperatureCelsius, _steepTimings, defaultToFavorite), _tea);
      Navigator.pop(context);
    }
  }
}

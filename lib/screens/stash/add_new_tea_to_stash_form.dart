import 'package:teavault/models/tea.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:teavault/models/tea_producer.dart';
import 'package:teavault/models/tea_producer_collection.dart';
import 'package:teavault/models/tea_production.dart';
import 'package:teavault/models/tea_production_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../tea_session_controller.dart';

class AddNewTeaToStash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Tea to Stash'),
      ),
      body: StashAddNewTeaForm(),
    );
  }
}

class StashAddNewTeaForm extends StatefulWidget {
  @override
  _StashAddNewTeaFormState createState() => new _StashAddNewTeaFormState();
}

class _StashAddNewTeaFormState extends State<StashAddNewTeaForm> {
  final _formKey = GlobalKey<FormState>();

  TeaProducer _producer;
  TeaProduction _production;
  int _quantity;

  //  Necessary for TextFormField select-all-on-focus
  static final _quantityInitialValue = '1';
  final _quantityFieldController = TextEditingController(text: _quantityInitialValue);
  FocusNode _quantityFieldFocusNode;

  @override
  initState() {
    super.initState();
    _quantityFieldFocusNode = FocusNode();

    //  Implements TextFormField select-all-on-focus
    _quantityFieldFocusNode.addListener(() {
      if (_quantityFieldFocusNode.hasFocus) {
        _quantityFieldController.selection = TextSelection(baseOffset: 0, extentOffset: _quantityInitialValue.length);
      }
    });
  }

  @override
  dispose() {
    _quantityFieldFocusNode.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<TeaProducer>> getProducerDropdownList(BuildContext context) {
    return Provider.of<TeaProducerCollectionModel>(context)
        .items
        .map((producer) => DropdownMenuItem(
              child: Text(producer.asString()),
              value: producer,
            ))
        .toList();
  }

  List<DropdownMenuItem<TeaProduction>> getProductionDropdownList(BuildContext context) {
    return Provider.of<TeaProductionCollectionModel>(context)
        .items
        .map((production) => DropdownMenuItem(
              child: Text(production.asString()),
              value: production,
            ))
        .where((dropdownListItem) => (_producer == null || dropdownListItem.value.producer == _producer))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: new ListView(children: <Widget>[
        DropdownButtonFormField(
          hint: Text('Select Producer'),
          items: getProducerDropdownList(context),
          value: _producer,
          onChanged: (value) {
            setState(() {
              _producer = value;
              if (_production != null && _production.producer != _producer) {
                _production = null;
              }
            });
          },
          isExpanded: true,
        ),
        DropdownButtonFormField(
            hint: Text('Select Production'),
            items: getProductionDropdownList(context),
            value: _production,
            onChanged: (value) {
              setState(() {
                _production = value;
                _producer = _production.producer;
              });
            },
            isExpanded: true),
        TextFormField(
            decoration: InputDecoration(labelText: 'Enter Quantity', hintText: 'Quantity'),
            validator: (value) {
              if (int.tryParse(value) == null) {
                return 'Please enter a valid quantity';
              }
              return null;
            },
            focusNode: _quantityFieldFocusNode,
            controller: _quantityFieldController,
            onSaved: (value) {
              setState(() {
                _quantity = int.parse(value);
              });
            },
            keyboardType: TextInputType.number),
        RaisedButton(
            color: Colors.blue,
            textColor: Colors.white,
            child: new Text('Add to Stash'),
            onPressed: () async {
              await addNewTeaFormSubmit(TeaSessionController.getTeaCollection(context));
            })
      ]),
    );
  }

  void addNewTeaFormSubmit(TeaCollectionModel teaCollection) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).unfocus(); //Dismiss the keyboard
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Adding new tea to stash...')));
      await teaCollection.add(Tea(_quantity, _production));
      Navigator.pop(context);
    }
  }
}

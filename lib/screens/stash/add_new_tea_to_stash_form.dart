import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:teavault/models/tea_producer.dart';
import 'package:teavault/models/tea_producer_collection.dart';
import 'package:teavault/models/tea_production.dart';
import 'package:teavault/models/tea_production_collection.dart';
import 'package:teavault/services/auth.dart';

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

class CommonOrCustomNewTeaSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Existing or Custom Production?'),
        ),
        body: Column(children: <Widget>[
          RaisedButton(
            child: Text('Choose Existing Production'),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => StashAddNewTeaForm(userDefined: false)));
            },
          ),
          RaisedButton(
              child: Text('Define Custom Production'),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => StashAddNewTeaForm(userDefined: true)));
              })
        ]));
  }
}

class StashAddNewTeaForm extends StatefulWidget {
  final bool userDefined;

  StashAddNewTeaForm({this.userDefined: false});

  @override
  StashAddNewTeaFormState createState() => new StashAddNewTeaFormState(this.userDefined);
}

class StashAddNewTeaFormState extends State<StashAddNewTeaForm> {
  static final TeaProducer userDefinedReservedProducerValue = TeaProducer('userDefinedReservedListValue', '');
  static final TeaProduction userDefinedReservedProductionValue =
      TeaProduction('userDefinedReservedListValue', 0, '', 0);

  bool _producerIsuserDefined = false;
  bool _productionIsUserDefined = false;

  String userDefinedProducerName;
  String userDefinedProducerShortName;

  String userDefinedProductionName;
  int userDefinedNominalWeightGrams;
  int userDefinedProductionYear;

  get userDefinedProducer => _producerIsuserDefined;
  get userDefinedProduction => _productionIsUserDefined;

  set userDefined(value) {
    setState(() {
      _producerIsuserDefined = value;
      _productionIsUserDefined = value;
    });
  }

  set userDefinedProduction(value) {
    setState(() {
      _productionIsUserDefined = value;
    });
  }

  final _formKey = GlobalKey<FormState>();

  TeaProducer _producer;
  TeaProduction _production;
  int _quantity;

  StashAddNewTeaFormState([userDefined]) {
    this._producerIsuserDefined = userDefined;
    this._productionIsUserDefined = userDefined;
  }

  TeaProducer get producer => this._producer;

  set producer(TeaProducer producer) {
    setState(() {
      _producer = producer;
      if (_production != null && _production.producer != _producer) {
        _production = null;
      }
    });
  }

  TeaProduction get production => this._production;

  set production(TeaProduction production) {
    setState(() {
      if (production != userDefinedReservedProductionValue) {
        this._producer = production.producer;
      }

      this._production = production;
    });
  }

  int get quantity => _quantity;

  set quantity(int value) {
    setState(() {
      _quantity = value;
    });
  }

  //  Necessary for TextFormField select-all-on-focus
  static final _quantityInitialValue = '1';
  final _quantityFieldController = TextEditingController(text: _quantityInitialValue);
  FocusNode _quantityFieldFocusNode;

  get quantityFieldController => _quantityFieldController;

  get quantityFieldFocusNode => _quantityFieldFocusNode;

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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: new ListView(children: <Widget>[
        this.userDefinedProducer ? Column(children: <Widget>[CreateProducerNameField(this), CreateProducerShortNameField(this)],) : ProducerDropdown(this),
        this.userDefinedProduction ? Column(children: <Widget>[CreateProductionNameField(this), CreateProductionYearField(this), CreateProductionWeightField(this)],) : ProductionDropdown(this),
        QuantityField(this),
        SubmitButton(this),
      ]),
    );
  }

  Future addNewTeaFormSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FocusScope.of(context).unfocus(); //Dismiss the keyboard
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Adding new tea to stash...')));

      if (userDefinedProducer) {
        final newProducer = await teaProducersCollection.put(TeaProducer(this.userDefinedProducerName, this.userDefinedProducerShortName, authService.lastKnownUserProfileId));
        this.producer = teaProducersCollection.getById(newProducer.documentID);
      }

      if (userDefinedProduction) {
        final newProduction = await teaProductionsCollection.put(TeaProduction(userDefinedProductionName, userDefinedNominalWeightGrams, this.producer.id, this.userDefinedProductionYear, authService.lastKnownUserProfileId));
        this._production = teaProductionsCollection.getById(newProduction.documentID);
      }

      await teasCollection.add(Tea(_quantity, _production.id));
      Navigator.pop(context);
    }
  }
}

class ProducerDropdown extends StatelessWidget {
  final StashAddNewTeaFormState state;

  ProducerDropdown(this.state);

  @override
  Widget build(
    BuildContext context,
  ) {
    final userSubmissionListItem = DropdownMenuItem(
      child: Text('Create Producer'),
      value: StashAddNewTeaFormState.userDefinedReservedProducerValue,
    );

    final listItems = [
          userSubmissionListItem,
        ] +
        teaProducersCollection.items
            .map((producer) => DropdownMenuItem(
                  child: Text(producer.asString()),
                  value: producer,
                ))
            .toList();
    return DropdownButtonFormField(
      hint: Text('Select Producer'),
      items: listItems,
      value: state.producer,
      validator: (value) {
        if (value == null) {
          return 'You must select a producer.';
        }

        return null;
      },
      onChanged: (value) {
        if (value == StashAddNewTeaFormState.userDefinedReservedProducerValue) {
          state.userDefined = true;
        } else {
          state.producer = value;
        }
      },
      isExpanded: true,
    );
  }
}

class CreateProducerNameField extends StatelessWidget {
  final StashAddNewTeaFormState state;

  CreateProducerNameField(this.state);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Enter Producer Name', hintText: 'Full Name'),
        validator: (value) {
          if (value.length == 0) {
            return 'Please enter a valid name';
          }
          return null;
        },
        onSaved: (value) {
          state.userDefinedProducerName = value;
        }
    );
  }
}

class CreateProducerShortNameField extends StatelessWidget {
  final StashAddNewTeaFormState state;

  CreateProducerShortNameField(this.state);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Enter Abbreviated Producer Name', hintText: 'Abbreviated Name'),
        validator: (value) {
          if (value.length == 0) {
            return 'Please enter a valid name';
          }
          return null;
        },
        onSaved: (value) {
          state.userDefinedProducerShortName = value;
        }
    );
  }
}

class ProductionDropdown extends StatelessWidget {
  final StashAddNewTeaFormState state;

  ProductionDropdown(this.state);

  @override
  Widget build(BuildContext context) {
    final userSubmissionListItem = DropdownMenuItem(
      child: Text('Create Production'),
      value: StashAddNewTeaFormState.userDefinedReservedProductionValue,
    );

    final listItems = [userSubmissionListItem,] + teaProductionsCollection.items
        .map((production) => DropdownMenuItem(
              child: Text(production.asString()),
              value: production,
            ))
        .where((dropdownListItem) => (state.producer == null || dropdownListItem.value.producer == state.producer))
        .toList();
    return Consumer<TeaProductionCollectionModel>(
      builder: (context, productions, child) => DropdownButtonFormField(
          hint: Text('Select Production'),
          value: state.production,
          validator: (value) {
            if (value == null) {
              return 'You must select a production.';
            }

            return null;
          },
          items: listItems,
          onChanged: (value) {
            if (value == StashAddNewTeaFormState.userDefinedReservedProductionValue) {
              state.userDefinedProduction = true;
            } else {
              state.production = value;
            }
          },
          isExpanded: true),
    );
  }
}

class CreateProductionNameField extends StatelessWidget {
  final StashAddNewTeaFormState state;

  CreateProductionNameField(this.state);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Enter Production Name', hintText: 'Production Name'),
        validator: (value) {
          if (value.length == 0) {
            return 'Please enter a valid name';
          }
          return null;
        },
        onSaved: (value) {
          state.userDefinedProductionName = value;
        }
    );
  }
}

class CreateProductionYearField extends StatelessWidget {
  final StashAddNewTeaFormState state;

  CreateProductionYearField(this.state);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Enter Production Year', hintText: 'Year of Production'),
        validator: (value) {
          if (int.tryParse(value) == null || int.tryParse(value) < 1940 || int.tryParse(value) > DateTime.now().year) {
            return 'Please enter a valid year between 1940 and ${DateTime.now().year}';
          }
          return null;
        },
        onSaved: (value) {
          state.userDefinedProductionYear = int.parse(value);
        },
        keyboardType: TextInputType.number);
  }
}

class CreateProductionWeightField extends StatelessWidget {
  final StashAddNewTeaFormState state;

  CreateProductionWeightField(this.state);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Enter Weight', hintText: 'Weight per Unit, in grams'),
        validator: (value) {
          if (int.tryParse(value) == null) {
            return 'Please enter a valid weight in grams';
          }
          return null;
        },
        onSaved: (value) {
          state.userDefinedNominalWeightGrams = int.parse(value);
        },
        keyboardType: TextInputType.number);
  }
}

class QuantityField extends StatelessWidget {
  final StashAddNewTeaFormState state;

  QuantityField(this.state);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(labelText: 'Enter Quantity', hintText: 'Quantity'),
        validator: (value) {
          if (int.tryParse(value) == null) {
            return 'Please enter a valid quantity';
          }
          return null;
        },
        focusNode: state.quantityFieldFocusNode,
        controller: state.quantityFieldController,
        onSaved: (value) {
          state.quantity = int.parse(value);
        },
        keyboardType: TextInputType.number);
  }
}

class SubmitButton extends StatelessWidget {
  final StashAddNewTeaFormState state;

  SubmitButton(this.state);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: new Text('Add to Stash'),
        onPressed: () async {
          await state.addNewTeaFormSubmit();
        });
  }
}

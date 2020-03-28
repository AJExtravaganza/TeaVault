import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teavault/screens/stash/stash_tea_form.dart';

class StashTeaAdd extends StatelessWidget {
  StashTeaAdd();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Add New Tea to Stash'),
      ),
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
              child: StashTeaForm(),
            ),
          ),
        ],
      ),
    );
  }
}

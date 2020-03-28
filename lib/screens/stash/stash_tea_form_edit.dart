import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/screens/stash/stash_tea_form.dart';

class StashTeaEdit extends StatelessWidget {
  final Tea tea;

  StashTeaEdit({this.tea});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Existing Tea in Stash'),
      ),
      body: StashTeaForm(true, this.tea),
    );
  }
}

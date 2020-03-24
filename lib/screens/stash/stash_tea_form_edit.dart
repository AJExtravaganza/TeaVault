import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:teavault/models/tea_producer.dart';
import 'package:teavault/models/tea_producer_collection.dart';
import 'package:teavault/models/tea_production.dart';
import 'package:teavault/models/tea_production_collection.dart';
import 'package:teavault/screens/stash/stash_tea_form.dart';
import 'package:teavault/services/auth.dart';

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
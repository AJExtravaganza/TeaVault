import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/services/auth.dart';
import 'package:teavault/models/tea_production.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

class TeaProductionCollectionModel extends ChangeNotifier {

  //Singleton class to allow global access
  static final TeaProductionCollectionModel _teaProductionCollectionModel = new TeaProductionCollectionModel._internal();

  factory TeaProductionCollectionModel() {
    return _teaProductionCollectionModel;
  }

  TeaProductionCollectionModel._internal();

  final String dbCollectionName = 'tea_productions';
  Map<String, TeaProduction> _items = {};
  bool _subscribedToDbChanges = false;

  UnmodifiableListView<TeaProduction> get items {
    List<TeaProduction> list = _items.values.toList();
    list.sort((TeaProduction a, TeaProduction b) => a.asString().compareTo(b.asString()));
    return UnmodifiableListView(list);
  }

  int get length => _items.length;

  TeaProduction getById(String id) => _items[id];

  bool contains(TeaProduction production) {
    return _items.values.any((existingProduction) => existingProduction == production);
  }

  Future<DocumentReference> put(TeaProduction production) async {
    final newDocumentReference = await Firestore.instance.collection(dbCollectionName).add(production.asMap());
    production.id = newDocumentReference.documentID;
    _items[newDocumentReference.documentID] = production;
    return newDocumentReference;
  }

  void subscribeToDb() {
    if (!_subscribedToDbChanges) {
      _subscribedToDbChanges = true;
      print('Subscribing to TeaProduction updates using profile id ${authService.lastKnownUserProfileId}');

      final globalUpdateStream = Firestore.instance.collection(dbCollectionName).where(
          'submitted_by_user_with_profile_id', isNull: true).snapshots();
      Stream updateStream;

      if (authService.lastKnownUserProfileId != null) {
        final personalUpdateStream = Firestore.instance.collection(dbCollectionName).where(
            'submitted_by_user_with_profile_id', isEqualTo: authService.lastKnownUserProfileId).snapshots();
        updateStream = StreamGroup.merge([globalUpdateStream, personalUpdateStream]);
      } else {
        updateStream = globalUpdateStream;
      }

      updateStream.listen((querySnapshot) {
        print('Got change to TeaProductions: ${querySnapshot.documentChanges.map((change) => change.document.documentID).toList().join(',')}');
        querySnapshot.documentChanges.forEach((documentChange) {
          final document = documentChange.document;
          if (documentChange.type == DocumentChangeType.removed) {
            this._items.remove(documentChange.document.documentID);
          } else {
            this._items[document.documentID] = TeaProduction.fromDocumentSnapshot(document);
          }
          notifyListeners();
        });
      });
    }
  }
}

final teaProductionsCollection = TeaProductionCollectionModel();
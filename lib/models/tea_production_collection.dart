import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/models/tea_producer_collection.dart';
import 'package:teavault/models/tea_production.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TeaProductionCollectionModel extends ChangeNotifier {
  final String dbCollectionName = 'tea_productions';
  TeaProducerCollectionModel producers;
  Map<String, TeaProduction> _items = {};

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

  TeaProductionCollectionModel(TeaProducerCollectionModel producers) {
    this.producers = producers;

    print('Subscribing to TeaProduction updates');
    final updateStream = Firestore.instance.collection(dbCollectionName).snapshots();
    updateStream.listen((querySnapshot) {
      querySnapshot.documentChanges.forEach((documentChange) {
        final document = documentChange.document;
        if (documentChange.type == DocumentChangeType.removed) {
          this._items.remove(documentChange.document.documentID);
        } else {
          this._items[document.documentID] = TeaProduction.fromDocumentSnapshot(document, producers);
        }
        print('Got change to TeaProduction ${document.documentID}');
        notifyListeners();
      });
    });
  }
}

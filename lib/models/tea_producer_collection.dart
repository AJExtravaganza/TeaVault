import 'dart:collection';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teavault/models/tea_producer.dart';
import 'package:teavault/services/auth.dart';

class TeaProducerCollectionModel extends ChangeNotifier {
//  Singleton class to allow global access
  static final TeaProducerCollectionModel _teaProducerCollectionModel = new TeaProducerCollectionModel._internal();

  factory TeaProducerCollectionModel() {
    return _teaProducerCollectionModel;
  }

  TeaProducerCollectionModel._internal();

  final String dbCollectionName = 'tea_producers';
  final Map<String, TeaProducer> _items = {};
  bool _subscribedToDbChanges = false;

  UnmodifiableListView<TeaProducer> get items {
    List<TeaProducer> list = _items.values.toList();
    list.sort((TeaProducer a, TeaProducer b) => a.asString().compareTo(b.asString()));
    return UnmodifiableListView(list);
  }

  int get length => _items.length;

  bool contains(TeaProducer producer) {
    return _items.values.any((existingProducer) => existingProducer == producer);
  }

  TeaProducer getById(String id) => _items[id];

  TeaProducer getByName(String name) => _items.values.singleWhere((producer) => producer.name == name);

  Future<DocumentReference> put(TeaProducer producer) async {
    if (!producer.isCustom) {
      throw Exception('Users may not modify non-custom producers');
    }

    final newDocumentReference = await Firestore.instance.collection(dbCollectionName).add(producer.asMap());
    producer.id = newDocumentReference.documentID;
//    _items[newDocumentReference.documentID] = producer;
    return newDocumentReference;
  }

  void subscribeToDb() {
    if (!_subscribedToDbChanges) {
      _subscribedToDbChanges = true;
      print('Subscribing to TeaProducer updates using profile id ${authService.lastKnownUserProfileId}');

      final globalUpdateStream = Firestore.instance
          .collection(dbCollectionName)
          .where('submitted_by_user_with_profile_id', isNull: true)
          .snapshots();
      Stream updateStream;

      if (authService.lastKnownUserProfileId != null) {
        final personalUpdateStream = Firestore.instance
            .collection(dbCollectionName)
            .where('submitted_by_user_with_profile_id', isEqualTo: authService.lastKnownUserProfileId)
            .snapshots();
        updateStream = StreamGroup.merge([globalUpdateStream, personalUpdateStream]);
      } else {
        updateStream = globalUpdateStream;
      }

      updateStream.listen((querySnapshot) {
        print(
            'Got changes to TeaProducers: ${querySnapshot.documentChanges.map((change) => change.document.documentID).toList().join(',')}');
        querySnapshot.documentChanges.forEach((documentChange) {
          final document = documentChange.document;
          if (documentChange.type == DocumentChangeType.removed) {
            this._items.remove(documentChange.document.documentID);
          } else {
            this._items[document.documentID] = TeaProducer.fromDocumentSnapshot(document);
          }
          notifyListeners();
        });
      });
    }
  }
}

final teaProducersCollection = TeaProducerCollectionModel();

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/models/user.dart';
import 'package:teavault/services/auth.dart';

class TeaCollectionModel extends ChangeNotifier {
  //Singleton class to allow global access
  static final TeaCollectionModel _teaCollectionModel = new TeaCollectionModel._internal();

  factory TeaCollectionModel() {
    return _teaCollectionModel;
  }

  TeaCollectionModel._internal();

  final String dbCollectionName = 'teas_in_stash';
  Map<String, Tea> _items = {};
  bool _subscribedToDbChanges = false;

  UnmodifiableListView<Tea> get items {
    List<Tea> list = _items.values.toList();
    list.sort((Tea a, Tea b) => a.asString().compareTo(b.asString()));
    return UnmodifiableListView(list);
  }

  int get length => _items.length;

  Tea getUpdated(Tea tea) => (tea != null && _items.containsKey(tea.id)) ? _items[tea.id] : null;

  Future add(Tea tea) async {
    if (_items.containsKey(tea.id)) {
      _items[tea.id].quantity += tea.quantity;
    } else {
      _items[tea.id] = tea;
    }

    await push(tea);
  }

  Future putBrewProfile(BrewProfile brewProfile, Tea tea) async {
    if (_items[tea.id]
            .brewProfiles
            .where((existingBrewProfile) => existingBrewProfile.name == brewProfile.name)
            .length >
        0) {
      throw Exception('A brew profile named ${brewProfile.name} already exists for this tea');
    }

    final updatedTea = Tea.copyFrom(_items[tea.id]);
    updatedTea.brewProfiles.add(brewProfile);
    await push(updatedTea);
  }

  Future updateBrewProfile(BrewProfile brewProfile, Tea tea) async {
    try {
      _items[tea.id].brewProfiles.remove(_items[tea.id]
          .brewProfiles
          .singleWhere((existingBrewProfile) => existingBrewProfile.name == brewProfile.name));
    } catch (err) {
      //ignore if not present
    }
    putBrewProfile(brewProfile, tea);
  }

  Future remove(Tea tea) async {
    await fetchUserProfile().then(
        (userProfile) async => await userProfile.reference.collection(dbCollectionName).document(tea.id).delete());
  }

  Future push(Tea tea) async {
    final userSnapshot = await fetchUserProfile();
    if (userSnapshot != null) {
      final teasCollection = await userSnapshot.reference.collection(dbCollectionName);
      await teasCollection.document(tea.id).setData(tea.asMap());
    }
  }

  Future subscribeToDb() async {
    if (!_subscribedToDbChanges) {
      _subscribedToDbChanges = true;
      print('Subscribing to Tea updates using profile id ${authService.lastKnownUserProfileId}');

      //TODO Extract teas_in_stash to root-level collection in schema, then make this look like the other collections.
      //TODO THEN extract common functionality into a "CollectionModel" superclass.
      final user = await fetchUserProfile();
      final updateStream = user.reference.collection(dbCollectionName).snapshots();

      updateStream.listen((querySnapshot) {
        print(
            'Got changes to TeasInStash: ${querySnapshot.documentChanges.map((change) => change.document.documentID).toList().join(',')}');
        querySnapshot.documentChanges.forEach((documentChange) {
          final document = documentChange.document;
          if (documentChange.type == DocumentChangeType.removed) {
            this._items.remove(documentChange.document.documentID);
          } else {
            try {
              final newTea = Tea.fromDocumentSnapshot(document);
              this._items[newTea.id] = newTea;
            } on Exception catch (err) {
              print('Error: $err\nTea not added to TeaCollection');
            }
          }
          notifyListeners();
        });
      });
    }
  }
}

final teasCollection = TeaCollectionModel();

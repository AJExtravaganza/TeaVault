import 'dart:collection';

import 'package:teavault/models/brewing_vessel.dart';
import 'package:flutter/widgets.dart';

class TeapotCollectionModel extends ChangeNotifier {
  final List<BrewingVessel> _items;

  UnmodifiableListView<BrewingVessel> get items => UnmodifiableListView(_items);

  int get length => _items.length;

  void resetToSampleList() {
    _items.removeWhere((BrewingVessel vessel) => true);
    _items.addAll(getSampleVesselList());
    notifyListeners();
  }

  TeapotCollectionModel(this._items);
}

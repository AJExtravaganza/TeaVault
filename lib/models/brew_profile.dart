import 'package:teavault/models/brewing_vessel.dart';

class BrewProfile {
  static String _DEFAULTNAME = 'defaultBrewProfileName';
  String _name;
  int nominalRatio; // expressed as integer n for ratio n:1 water:leaf
  int brewTemperatureCelsius; // expressed in degrees Celsius
  List<int> steepTimings;
  bool isFavorite;

  List<int> get trimmedSteepTimings => _trimSteepTimingsList(steepTimings);

  String get name => this._name == _DEFAULTNAME ? 'Default' : _name;
  set name(String newName) {
    if (this == getDefault()) {
      throw Exception('You cannot change the name of the default BrewProfile');
    } else {
      this._name = newName;
    }
  }

  int get steeps => steepTimings.length;

  Map<String, dynamic> asMap() => {
        'name': name,
        'nominal_ratio': nominalRatio,
        'brew_temperature_celsius': brewTemperatureCelsius,
        'steep_timings': _trimSteepTimingsList(steepTimings),
        'is_favorite': isFavorite
      };

  BrewProfile(this._name, this.nominalRatio, this.brewTemperatureCelsius, this.steepTimings, [this.isFavorite = false]);

  static List<int> _trimSteepTimingsList(List<int> steepTimingsList) {
    bool timedSteepFound = false;
    List<int> trimmedList = [];
    steepTimingsList.forEach((value) {
      if (value != 0) {
        timedSteepFound = true;
        trimmedList.add(value);
      } else if (!timedSteepFound) {
        trimmedList.add(value);
      }
    });

    return trimmedList;
  }

  static BrewProfile fromJson(Map<String, dynamic> json) {
    List<int> steepTimings = List<int>.from(json['steep_timings']);
    return BrewProfile(
        json['name'], json['nominal_ratio'], json['brew_temperature_celsius'], steepTimings, json['is_favorite']);
  }

  static BrewProfile getDefault() {
    List<int> sampleTimingList = [10, 5, 8, 10, 20, 30, 60];
    return BrewProfile(_DEFAULTNAME, 15, 100, sampleTimingList);
  }

  double getDose(BrewingVessel vessel) {
    return vessel.volumeMilliliters / this.nominalRatio;
  }

  @override
  bool operator ==(other) =>  other.name == this.name;

  static int compare(a, b) {
    if (a.isFavorite && !b.isFavorite) {
      return -1;
    } else if (b.isFavorite && !a.isFavorite) {
      return 1;
    } else {
      return a.name.compareTo(b.name);
    }
  }
}

import 'package:teavault/models/brewing_vessel.dart';

class BrewProfile {
  String name;
  int nominalRatio; // expressed as integer n for ratio n:1 water:leaf
  int brewTemperatureCelsius; // expressed in degrees Celsius
  List<int> steepTimings;
  bool isFavorite;

  int get steeps => steepTimings.length;

  Map<String, dynamic> asMap() => {
        'name': name,
        'nominal_ratio': nominalRatio,
        'brew_temperature_celsius': brewTemperatureCelsius,
        'steep_timings': _trimSteepTimingsList(steepTimings),
        'is_favorite': isFavorite
      };

  BrewProfile(this.name, this.nominalRatio, this.brewTemperatureCelsius, this.steepTimings, [this.isFavorite = false]);

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
    return BrewProfile('Default', 15, 100, sampleTimingList);
  }

  double getDose(BrewingVessel vessel) {
    return vessel.volumeMilliliters / this.nominalRatio;
  }

  @override
  bool operator ==(other) =>  other.name == this.name;
}

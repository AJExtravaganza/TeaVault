import 'dart:async';
import 'dart:math';

import 'package:provider/provider.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/brewing_vessel.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

class TeaSessionController extends ChangeNotifier {
  Tea _currentTea;
  BrewProfile _brewProfile;
  BrewingVessel brewingVessel;
  int _currentSteep = 0;

  Timer _timer;
  Duration _timeRemaining;
  bool _finished = false;

  bool _deviceHasVibrator = false;
  bool _muted = false;

  Duration get timeRemaining => _timeRemaining;

  bool get active => _timer != null && _timer.isActive;

  bool get finished => _finished;

  bool get muted => _muted;

  int get currentSteep => _currentSteep;

  set currentSteep(int value) {
    if (value >= 0 && value < brewProfile.steepTimings.length) {
      _currentSteep = value;
      _resetTimer();
      notifyListeners();
    } else {
      throw Exception('No steepTimings element at index $value in active BrewProfile');
    }
  }

  int get steepsRemainingInProfile => _brewProfile.steepTimings.length - currentSteep;

  get currentTea => _currentTea;

  set currentTea(Tea newTea) {
    _currentTea = newTea;
    if (newTea != null) {
      _brewProfile = newTea.defaultBrewProfile;
    } else {
      _brewProfile = BrewProfile.getDefault();
    }
    _currentSteep = 0;
    _resetTimer();
    notifyListeners();
  }

  get brewProfile => _brewProfile != null ? _brewProfile : BrewProfile.getDefault();

  set brewProfile(BrewProfile brewProfile) {
    _brewProfile = brewProfile;
    _currentSteep = 0;
    _resetTimer();
    notifyListeners();
  }

  void updateCurrentTeaRecord(TeaCollectionModel teaCollectionModel) {
    this._currentTea = teaCollectionModel.getUpdated(_currentTea);
    try {
      _brewProfile = _currentTea.brewProfiles.singleWhere((brewProfile) => brewProfile == _brewProfile);
    } catch (err) {
      _brewProfile = null;
    }

    notifyListeners();
  }

  saveSteepTimeToBrewProfile(int steep, int timeInSeconds) async {
    brewProfile.steepTimings[steep] = timeInSeconds;
    await teasCollection.push(currentTea);
  }

  TeaSessionController(TeaCollectionModel teaCollectionModel) {
    _currentTea = null;
    _brewProfile = null;
    brewingVessel = getSampleVesselList().first;

    Vibration.hasVibrator().then((hasVibration) {
      _deviceHasVibrator = hasVibration;
    });
  }

  set muted(bool state) {
    _muted = state;
    notifyListeners();
  }

  decrementSteep() {
    currentSteep = max(_currentSteep - 1, 0);

    if (_timer != null) {
      _timer.cancel();
    }

    _resetTimer();
    notifyListeners();
  }

  incrementSteep() {
    currentSteep = min(_currentSteep + 1, _brewProfile.steepTimings.length);

    if (_timer != null) {
      _timer.cancel();
    }

    _resetTimer();
    notifyListeners();
  }

  _resetTimer() {
    _cancelBrewTimer();
    _finished = false;
    _timeRemaining = Duration(seconds: _brewProfile.steepTimings[_currentSteep]);
  }

  set timeRemaining(Duration newTimeRemaining) {
    _timeRemaining = newTimeRemaining;
    notifyListeners();
  }

  void _cancelBrewTimer() {
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
  }

  void startBrewTimer() {
    if (_timer == null || !_timer.isActive) {
      const oneSecond = Duration(seconds: 1);
      _timer = new Timer.periodic(oneSecond, (Timer timer) {
        if (_timeRemaining > Duration(seconds: 0)) {
          _timeRemaining -= Duration(seconds: 1);
          notifyListeners();
        }

        if (!(_timeRemaining > Duration(seconds: 0))) {
          _finished = true;
          timer.cancel();
          notifyListeners();
          if (_deviceHasVibrator) {
            Vibration.vibrate(duration: 1000, amplitude: 255);
          }
          if (!_muted || !_deviceHasVibrator) {
            FlutterRingtonePlayer.playNotification();
          }
        }
      });
    }
  }

  void stopBrewTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    notifyListeners();
  }
}

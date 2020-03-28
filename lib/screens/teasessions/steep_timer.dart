import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/tea_session_controller.dart';

import 'helper_functions.dart';

class SteepTimer extends StatelessWidget {
  final TeaSessionController controller;

  SteepTimer(this.controller);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[TimerDisplayRow(controller), SteepCountRow(controller), SteepTimerControls(controller)],
    );
  }
}

class TimerDisplayRow extends StatelessWidget {
  final TeaSessionController controller;

  TimerDisplayRow(this.controller);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 2,
          child: TimerIconButton(),
        ),
        Expanded(flex: 12, child: TimerDisplay(controller)),
        Expanded(
          flex: 2,
          child: TimerMuteIconButton(controller),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}

class TimerDisplay extends StatelessWidget {
  final TeaSessionController controller;

  TimerDisplay(this.controller);

  @override
  Widget build(BuildContext context) {
    final mainContext = context;
    String currentValueStr = controller.timeRemaining.toString().split('.').first.substring(2);

    Text timerTextContent;
    if (controller.timeRemaining.inSeconds == 0 && !controller.finished) {
      if (controller.currentSteep == 0) {
        timerTextContent = Text(
          'FLASH',
          style: TextStyle(height: 1.4, fontSize: 60, fontFamily: 'RobotoMonoCondensed'),
        );
      } else {
        timerTextContent = Text(
          '--:--',
          style: TextStyle(fontSize: 72, fontFamily: 'RobotoMono'),
        );
      }
    } else {
      timerTextContent = Text(
        currentValueStr,
        style: TextStyle(fontSize: 72, fontFamily: 'RobotoMono'),
      );
    }

    return FlatButton(
      child: timerTextContent,
      onPressed: haptic(() {
        controller.stopBrewTimer();

        showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: Colors.white,
            builder: (context) => TimerPickerSheetContents(controller, mainContext));
      }),
    );
  }
}

class TimerPickerSheetContents extends StatefulWidget {
  final TeaSessionController controller;
  final BuildContext mainContext;

  TimerPickerSheetContents(this.controller, this.mainContext);

  @override
  State<StatefulWidget> createState() => TimerPickerSheetContentsState(this.controller, this.mainContext);
}

class TimerPickerSheetContentsState extends State<TimerPickerSheetContents> {
  final TeaSessionController controller;
  final BuildContext mainContext;

  int _selectedValueInSeconds;

  TimerPickerSheetContentsState(this.controller, this.mainContext);

  @override
  Widget build(BuildContext context) {
    _selectedValueInSeconds = controller.currentBrewProfile.steepTimings[controller.currentSteep];
    ;
    final orientation = MediaQuery.of(context).orientation;
    final portrait = Orientation.portrait;
    int buttonFlex = orientation == portrait ? 15 : 20;
    int timerPickerFlex = orientation == portrait ? 50 : 40;

    bool showSaveButton = (controller.currentTea != null && controller.currentBrewProfile != BrewProfile.getDefault());

    return Container(
        height: 200,
        color: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10.0),
                  topRight: const Radius.circular(10.0),
                )),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: buttonFlex,
                  child: showSaveButton ? TimerPickerSaveButton(controller) : Container(),
                ),
                Expanded(
                  flex: timerPickerFlex,
                  child: BrewTimerPicker(),
                ),
                Expanded(
                  flex: buttonFlex,
                  child: TimerPickerSheetDismissButton(controller),
                ),
              ],
            )));
  }
}

class TimerPickerSaveButton extends StatelessWidget {
  final TeaSessionController controller;

  TimerPickerSaveButton(this.controller);

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<TimerPickerSheetContentsState>();
    return IconButton(
      onPressed: haptic(() async {
        this.controller.timeRemaining = Duration(seconds: state._selectedValueInSeconds);
        Navigator.pop(context);
        Scaffold.of(state.mainContext).showSnackBar(SnackBar(content: Text("Saving change to brew profile...")));
        await controller.saveSteepTimeToBrewProfile(controller.currentSteep, state._selectedValueInSeconds);
      }),
      icon: Icon(Icons.save_alt),
      iconSize: 48,
    );
  }
}

class BrewTimerPicker extends StatelessWidget {
  BrewTimerPicker();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<TimerPickerSheetContentsState>();
    return CupertinoTimerPicker(
        mode: CupertinoTimerPickerMode.ms,
        initialTimerDuration: Duration(seconds: state._selectedValueInSeconds),
        onTimerDurationChanged: (Duration newDuration) {
          state._selectedValueInSeconds = newDuration.inSeconds;
        });
  }
}

class TimerPickerSheetDismissButton extends StatelessWidget {
  final TeaSessionController controller;

  TimerPickerSheetDismissButton(this.controller);

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<TimerPickerSheetContentsState>();
    return IconButton(
      onPressed: haptic(() {
        controller.timeRemaining = Duration(seconds: state._selectedValueInSeconds);
        Navigator.pop(context);
      }),
      icon: Icon(Icons.check_box),
      iconSize: 48,
    );
  }
}

class SteepCountRow extends StatelessWidget {
  final TeaSessionController controller;

  SteepCountRow(this.controller);

  String getSteepText(int steep) {
    return steep == 0 ? 'Rinse' : 'Steep $steep';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Text(
            getSteepText(controller.currentSteep),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}

class TimerIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.timelapse);
  }
}

class TimerMuteIconButton extends StatelessWidget {
  final TeaSessionController controller;

  TimerMuteIconButton(this.controller);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: haptic(() => controller.muted = !controller.muted),
      alignment: Alignment.center,
      icon: Icon(controller.muted ? Icons.notifications_off : Icons.notifications_active),
    );
  }
}

class SteepTimerControls extends StatelessWidget {
  final TeaSessionController controller;

  SteepTimerControls(this.controller);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 3,
          child: PreviousSteepButton(controller),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 3,
          child: BrewButton(controller),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 3,
          child: NextSteepButton(controller),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }
}

class PreviousSteepButton extends StatelessWidget {
  final TeaSessionController controller;

  PreviousSteepButton(this.controller);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: haptic(controller.decrementSteep),
      icon: Icon(Icons.arrow_back_ios),
      alignment: Alignment.center,
    );
  }
}

class BrewButton extends StatelessWidget {
  final TeaSessionController controller;

  BrewButton(this.controller);

  @override
  Widget build(BuildContext context) {
    if (controller.active) {
      return IconButton(
        onPressed: haptic(() => controller.stopBrewTimer()),
        icon: Icon(Icons.pause),
        alignment: Alignment.center,
      );
    } else if (controller.timeRemaining.inSeconds > 0) {
      return IconButton(
        onPressed: haptic(() => controller.startBrewTimer()),
        icon: Icon(Icons.play_arrow),
        alignment: Alignment.center,
      );
    } else {
      //Disable for Flash Steep
      return IconButton(
        onPressed: () {},
        icon: Icon(Icons.play_arrow),
        alignment: Alignment.center,
      );
    }
  }
}

class NextSteepButton extends StatelessWidget {
  final TeaSessionController controller;

  NextSteepButton(this.controller);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: haptic(() {
          final steepTimings = controller.currentBrewProfile.steepTimings;
          if (controller.steepsRemainingInProfile > 1) {
            controller.incrementSteep();
          } else if (steepTimings[controller.currentSteep] != 0 || controller.currentSteep == 0) {
            steepTimings.add(0);
            controller.incrementSteep();
          }
        }),
        icon: Icon(Icons.arrow_forward_ios));
  }
}

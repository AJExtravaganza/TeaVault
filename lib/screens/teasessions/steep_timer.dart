import 'package:teavault/tea_session_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class SteepTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[TimerDisplayRow(), SteepCountRow(), SteepTimerControls()],
    );
  }
}

class SteepCountRow extends StatelessWidget {
  String getSteepText(int steep) {
    return steep == 0 ? 'Rinse' : 'Steep ${steep}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeaSessionController>(
        builder: (context, activeTeaSession, child) => Row(
              children: <Widget>[
                Expanded(
                  flex: 10,
                  child: Text(
                    getSteepText(activeTeaSession.currentSteep),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ));
  }
}

class TimerDisplayRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeaSessionController>(
        builder: (context, activeTeaSession, child) => Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: TimerIconButton(),
                ),
                Expanded(flex: 12, child: TimerDisplay()),
                Expanded(
                  flex: 2,
                  child: TimerMuteIconButton(),
                ),
                Expanded(
                  flex: 3,
                  child: Container(),
                ),
              ],
            ));
  }
}

class TimerDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _context = context;
    final teaSessionController = Provider.of<TeaSessionController>(context, listen: false);

    String currentValueStr = teaSessionController.timeRemaining.toString().split('.').first.substring(2);

    Text timerTextContent;
    if (teaSessionController.timeRemaining.inSeconds == 0 && !teaSessionController.finished) {
      if (teaSessionController.currentSteep == 0) {
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
      onPressed: () {
        teaSessionController.stopBrewTimer();

        showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: Colors.white,
            builder: (context) => TimerPickerSheetContents(_context, teaSessionController));
      },
    );
  }
}

class TimerPickerSheetContents extends StatefulWidget {
  final TeaSessionController teaSessionController;
  final BuildContext _parentContext;

  TimerPickerSheetContents(this._parentContext, this.teaSessionController);

  @override
  State<StatefulWidget> createState() => TimerPickerSheetContentsState(this._parentContext, this.teaSessionController);
}

class TimerPickerSheetContentsState extends State<TimerPickerSheetContents> {
  final TeaSessionController teaSessionController;
  final BuildContext _parentContext;
  int _selectedValueInSeconds;

  TimerPickerSheetContentsState(this._parentContext, this.teaSessionController);

  @override
  Widget build(BuildContext context) {
    _selectedValueInSeconds = teaSessionController.brewProfile.steepTimings[teaSessionController.currentSteep];
    ;
    final orientation = MediaQuery.of(context).orientation;
    final portrait = Orientation.portrait;
    int buttonFlex = orientation == portrait ? 15 : 20;
    int timerPickerFlex = orientation == portrait ? 50 : 40;

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
                  child: teaSessionController.currentTea != null
                      ? IconButton(
                          onPressed: () async {
                            this.teaSessionController.timeRemaining = Duration(seconds: this._selectedValueInSeconds);
                            Navigator.pop(context);
                            Scaffold.of(_parentContext)
                                .showSnackBar(SnackBar(content: Text("Saving change to brew profile...")));
                            await teaSessionController.saveSteepTimeToBrewProfile(
                                teaSessionController.currentSteep, this._selectedValueInSeconds);
                          },
                          icon: Icon(Icons.save_alt),
                          iconSize: 48,
                        )
                      : Container(),
                ),
                Expanded(
                  flex: timerPickerFlex,
                  child: BrewTimerPicker(),
                ),
                Expanded(
                  flex: buttonFlex,
                  child: IconButton(
                    onPressed: () {
                      this.teaSessionController.timeRemaining = Duration(seconds: this._selectedValueInSeconds);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.check_box),
                    iconSize: 48,
                  ),
                ),
              ],
            )));
  }
}

class BrewTimerPicker extends StatelessWidget {
  BrewTimerPicker();

  @override
  Widget build(BuildContext context) {
    final parentWidgetState = context.findAncestorStateOfType<TimerPickerSheetContentsState>();
    return CupertinoTimerPicker(
        mode: CupertinoTimerPickerMode.ms,
        initialTimerDuration: Duration(seconds: parentWidgetState._selectedValueInSeconds),
        onTimerDurationChanged: (Duration newDuration) {
          parentWidgetState._selectedValueInSeconds = newDuration.inSeconds;
        });
  }
}

class TimerIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      alignment: Alignment.center,
      icon: Icon(Icons.timelapse),
    );
  }
}

class TimerMuteIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teaSessionController = Provider.of<TeaSessionController>(context, listen: false);

    return IconButton(
      onPressed: () {
        teaSessionController.muted = !teaSessionController.muted;
      },
      alignment: Alignment.center,
      icon: Icon(teaSessionController.muted ? Icons.notifications_off : Icons.notifications_active),
    );
  }
}

class SteepTimerControls extends StatelessWidget {
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
          child: PreviousSteepButton(),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 3,
          child: BrewButton(),
        ),
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 3,
          child: NextSteepButton(),
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
  @override
  Widget build(BuildContext context) {
    final teaSessionController = Provider.of<TeaSessionController>(context);

    return IconButton(
      onPressed: teaSessionController.decrementSteep,
      icon: Icon(Icons.arrow_back_ios),
      alignment: Alignment.center,
    );
  }
}

class BrewButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teaSessionController = Provider.of<TeaSessionController>(context, listen: false);

    if (teaSessionController.active) {
      return IconButton(
        onPressed: teaSessionController.stopBrewTimer,
        icon: Icon(Icons.pause),
        alignment: Alignment.center,
      );
    } else if (teaSessionController.timeRemaining.inSeconds > 0) {
      return IconButton(
        onPressed: teaSessionController.startBrewTimer,
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
  @override
  Widget build(BuildContext context) {
    final teaSessionController = Provider.of<TeaSessionController>(context, listen: false);
    return IconButton(
        onPressed: () {
          final steepTimings = teaSessionController.brewProfile.steepTimings;
          if (teaSessionController.steepsRemainingInProfile > 1) {
            teaSessionController.incrementSteep();
          } else if (steepTimings[teaSessionController.currentSteep] != 0 || teaSessionController.currentSteep == 0) {
            steepTimings.add(0);
            teaSessionController.incrementSteep();
          }
        },
        icon: Icon(Icons.arrow_forward_ios));
  }
}

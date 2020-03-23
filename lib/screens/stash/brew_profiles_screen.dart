import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/tea.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:teavault/tea_session_controller.dart';

import 'brew_profile_form_add.dart';
import 'brew_profile_form_edit.dart';

class BrewProfilesScreen extends StatelessWidget {
  Tea _tea;
  final bool suppressTileMenu;

  BrewProfilesScreen(this._tea, {this.suppressTileMenu = false});

  @override
  Widget build(BuildContext context) {
    this._tea = teasCollection.getUpdated(_tea);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Brew Profile'),
      ),
      body: BrewProfilesListView(this._tea, suppressTileMenu: this.suppressTileMenu),
    );
  }
}

enum BrewProfilesTileInteraction { edit, setFavorite, delete }

class BrewProfilesListItem extends StatelessWidget {
  final BrewProfile _brewProfile;
  final Tea _tea;
  final bool suppressTileMenu;

  BrewProfilesListItem(this._brewProfile, this._tea, {this.suppressTileMenu = false});

  String steepTimeAsHMS(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 60 * 60) {
      int minutes = seconds ~/ 60;
      seconds %= 60;
      return seconds > 0 ? '${minutes}m${seconds}s' : '${minutes}m';
    } else {
      int hours = seconds ~/ 3600;
      int minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '${hours}h${minutes}m' : '${hours}h';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: FlutterLogo(size: 72.0),
        title: Text(_brewProfile.name),
        subtitle: Text('1:${_brewProfile.nominalRatio}, ${_brewProfile.brewTemperatureCelsius}°C' +
            '\n'
                '${_brewProfile.trimmedSteepTimings.map(steepTimeAsHMS).join('/')}'),
        trailing: this.suppressTileMenu
            ? Container(width: 1, height: 1)
            : PopupMenuButton<BrewProfilesTileInteraction>(
                onSelected: (BrewProfilesTileInteraction result) {
                  if (result == BrewProfilesTileInteraction.edit) {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => EditBrewProfileScreen(_tea, _brewProfile)));
                  } else if (result == BrewProfilesTileInteraction.setFavorite) {
                    _tea.setBrewProfileAsFavorite(_brewProfile);
                  } else if (result == BrewProfilesTileInteraction.delete) {
                    _tea.removeBrewProfile(_brewProfile);
                  } else {
                    throw Exception('You managed to select an invalid StashTileInteraction.  Good job, guy.');
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<BrewProfilesTileInteraction>>[
                  const PopupMenuItem<BrewProfilesTileInteraction>(
                    value: BrewProfilesTileInteraction.edit,
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem<BrewProfilesTileInteraction>(
                    value: BrewProfilesTileInteraction.setFavorite,
                    child: Text('Set Favorite'),
                  ),
                  const PopupMenuItem<BrewProfilesTileInteraction>(
                    value: BrewProfilesTileInteraction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
        isThreeLine: true,
        onTap: () {
          final teaSessionController = Provider.of<TeaSessionController>(context, listen: false);
          teaSessionController.currentTea = this._tea;
          teaSessionController.currentBrewProfile = this._brewProfile;
          Navigator.pop(context);
        },
      ),
    );
  }
}

class BrewProfilesListView extends Consumer<TeaCollectionModel> {
  BrewProfilesListView(tea, {suppressTileMenu: false})
      : super(builder: (context, teas, child) {
          tea = teas.getUpdated(tea);

          if (tea.brewProfiles.length == 0) {
            return AddBrewProfileWidget(tea);
          }

          return Column(children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: tea.brewProfiles.length,
                  itemBuilder: (BuildContext context, int index) =>
                      BrewProfilesListItem(tea.brewProfiles[index], tea, suppressTileMenu: suppressTileMenu)),
            ),
            AddBrewProfileWidget(tea)
          ]);
        });
}

class AddBrewProfileWidget extends StatelessWidget {
  final Tea tea;

  AddBrewProfileWidget(this.tea);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Row(
      children: <Widget>[
        Expanded(
            child: Center(
                child: RaisedButton(
          child: Text("Add New Brew Profile"),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewBrewProfileScreen(tea)));
          },
        )))
      ],
    ));
  }
}

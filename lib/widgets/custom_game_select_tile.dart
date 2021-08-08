import 'dart:convert';
import 'dart:ui';

import 'package:Drinkr/utils/custom.dart';
import 'package:Drinkr/menus/game_mode.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/widgets/custom_switch.dart';
import 'package:Drinkr/widgets/game_select_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomGameSelectTile extends GameSelectTile {
  CustomGameSelectTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<GameType> enabledGames,
    required List<Player> players,
    required ValueChanged<CurrentGameState> onGameStateChange,
    required BuildContext parentContext,
    required bool enabled,
    required List<Color> backgroundColors,
  }) : super(
            icon: icon,
            title: title,
            subtitle: subtitle,
            enabledGames: enabledGames,
            players: players,
            onGameStateChange: onGameStateChange,
            parentContext: parentContext,
            enabled: enabled,
            backgroundColors: backgroundColors);

  @override
  _CustomGameSelectTileState createState() => _CustomGameSelectTileState();
}

class _CustomGameSelectTileState extends GameSelectTileState {
  @override
  bool hasAdultGames() {
    return true;
  }

  @override
  bool adultSwitchEnabled() {
    return super.hasAdultGames();
  }

  Future<void> loadSave() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String>? stringList = sp.getStringList(SAVED_CUSTOM_SETTING);
    if (stringList == null) return;
    for (String entry in stringList) {
      dynamic jsonObject = JsonDecoder().convert(entry);
      String savedName = jsonObject["name"];
      bool savedValue = jsonObject["value"];
      GameType? determinedType;
      for (GameType type in GameType.values) {
        if (gameTypeToGameTypeClass(type).filePrefix == savedName) {
          determinedType = type;
          break;
        }
      }
      if (determinedType == null) {
        continue;
      }

      if (!savedValue && widget.enabledGames.contains(determinedType)) {
        widget.enabledGames.remove(determinedType);
      }
      if (savedValue && !widget.enabledGames.contains(determinedType)) {
        widget.enabledGames.add(determinedType);
      }
    }
  }

  Future<void> saveSave() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> stringList = [];
    List<GameType> allGames = GameType.values
        .where((element) => element != GameType.UNDEFINED)
        .toList();
    for (GameType type in allGames) {
      stringList.add(
        JsonEncoder().convert(
          {
            "name": gameTypeToGameTypeClass(type).filePrefix,
            "value": widget.enabledGames.contains(type)
          },
        ),
      );
    }
    await sp.setStringList(SAVED_CUSTOM_SETTING, stringList);
  }

  @override
  void initState() {
    loadSave().then((value) {
      for (GameType type in widget.enabledGames) {
        keys[type]?.currentState?.controller.forward();
      }
      setState(() {});
    });
    super.initState();
  }

  Map<GameType, GlobalKey<CustomSwitchState>> keys =
      Map.fromEntries(GameType.values
          .map(
            (e) => MapEntry(
              e,
              GlobalKey<CustomSwitchState>(),
            ),
          )
          .toList());

  @override
  Widget enabledGamesSelection() {
    return Column(
      children: [
        Divider(
          thickness: 3,
          color: Colors.white,
        ),
        for (TypeClass type in GameType.values
            .where((element) =>
                ![GameType.DARE, GameType.UNDEFINED].contains(element))
            .map((e) => gameTypeToGameTypeClass(e)))
          GestureDetector(
            onTap: () {
              bool value = !widget.enabledGames.contains(type.type);
              setState(() {
                if (value) {
                  widget.enabledGames.add(type.type);
                } else {
                  widget.enabledGames.remove(type.type);
                }
              });
              if (value) {
                keys[type.type]!.currentState?.controller.forward();
              } else {
                keys[type.type]!.currentState?.controller.reverse();
              }
              saveSave();
            },
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "\u2022 " + type.translatedTitle,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              dense: true,
              trailing: CustomSwitch(
                onChanged: (bool value) {
                  setState(
                    () {
                      if (value) {
                        widget.enabledGames.add(type.type);
                      } else {
                        widget.enabledGames.remove(type.type);
                      }
                    },
                  );
                  saveSave();
                },
                value: widget.enabledGames.contains(type.type),
                activeColor: Colors.orange,
                enabled: widget.enabled,
                key: keys[type.type],
              ),
            ),
          )
      ],
    );
  }
}

import 'dart:convert';
import 'dart:ui';

import 'package:drinkr/utils/custom.dart';
import 'package:drinkr/menus/game_mode.dart';
import 'package:drinkr/utils/player.dart';
import 'package:drinkr/utils/types.dart';
import 'package:drinkr/widgets/custom_switch.dart';
import 'package:drinkr/widgets/game_select_tile.dart';
import 'package:easy_localization/easy_localization.dart';
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
    List<String>? stringList = sp.getStringList(savedCustomSetting);
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
        .where((element) => element != GameType.undefined)
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
    await sp.setStringList(savedCustomSetting, stringList);
  }

  @override
  void initState() {
    loadSave().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget enabledGamesSelection() {
    return Column(
      children: [
        Divider(
          thickness: 1,
          color: Colors.white,
        ),
        for (TypeClass type in GameType.values
            .where((element) =>
                ![GameType.dare, GameType.undefined].contains(element))
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
              saveSave();
            },
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                type.type == GameType.truth
                    ? "\u2022 " + tr("truthOrDare")
                    : "\u2022 " + type.translatedTitle,
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
                activeColor: Colors.black.withOpacity(.4),
                enabled: widget.enabled,
              ),
            ),
          )
      ],
    );
  }
}

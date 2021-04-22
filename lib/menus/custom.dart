import 'dart:convert';
import 'dart:math';

import 'package:Drinkr/menus/difficulty.dart';
import 'package:Drinkr/utils/shapes.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/file.dart';
import 'name_select.dart';
import '../utils/player.dart';
import 'setting.dart';
import '../utils/types.dart';

class Custom extends StatefulWidget {
  @override
  CustomState createState() => CustomState();
}

const String SAVED_CUSTOM_SETTING = "SAVED_CUSTOM_SETTING";

class CustomState extends State<StatefulWidget> {
  Map<GameType, bool> selectedItems = Map();
  Map<GameType, bool> itemActivated = Map();

  Future<void> loadSave() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> stringList = sp.getStringList(SAVED_CUSTOM_SETTING);
    if (stringList == null) return;
    for (String entry in stringList) {
      dynamic jsonObject = JsonDecoder().convert(entry);
      String savedName = jsonObject["name"];
      bool savedValue = jsonObject["value"];
      GameType determinedType;
      for (GameType type in GameType.values) {
        if (gameTypeToGameTypeClass(type).filePrefix == savedName) {
          determinedType = type;
          break;
        }
      }
      if (determinedType == null) continue;
      selectedItems[determinedType] = savedValue;
    }
  }

  Future<void> saveSave() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> stringList = List<String>();
    for (GameType type in selectedItems.keys) {
      stringList.add(JsonEncoder().convert({
        "name": gameTypeToGameTypeClass(type).filePrefix,
        "value": selectedItems[type]
      }));
    }
    await sp.setStringList(SAVED_CUSTOM_SETTING, stringList);
  }

  @override
  void initState() {
    super.initState();

    for (GameType type in GameType.values) {
      if ([GameType.UNDEFINED, GameType.DARE].contains(type)) continue;
      selectedItems[type] = true;
      itemActivated[type] = true;
    }

    SharedPreferences.getInstance().then((sp) async {
      if (sp.getInt(SettingsState.SETTING_INCLUSION_OF_QUESTIONS) ==
          SettingsState.ONLY_CUSTOM) {
        for (GameType type in itemActivated.keys) {
          int number = await getNumberOfTextsLocal(enabledGames: [type]);
          if (number == 0) {
            itemActivated[type] = false;
            selectedItems[type] = false;
          }
        }
        setState(() {});
      }
    });

    loadSave().then((value) => setState(() {}));
  }

  void confirm() {
    List availableGames =
        selectedItems.keys.where((element) => selectedItems[element]).toList();

    if (availableGames.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.orange,
            title: Text("customNoGameSelected",
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(color: Colors.black  ),
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                )).tr(),
            content: Text(
              "customNoGameSelectedDescription",
              style: GoogleFonts.nunito(
                textStyle: TextStyle(color: Colors.black),
                fontSize: 25,
              ),
            ).tr(),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              MaterialButton(
                child: Text(
                  "close",
                  style: GoogleFonts.nunito(color: Colors.black, fontSize: 20),
                ).tr(),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    } else {
      bool playersRequired = false;

      availableGames.forEach((element) => playersRequired =
          gameTypeToGameTypeClass(element).includesPlayers || playersRequired);

      if (playersRequired) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NameSelect(availableGames)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Difficulty([Player("")], 100, availableGames)));
      }
    }
  }

  ScrollController _scrollControl = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        title: Text(
          "customTitle",
          style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ).tr(),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      body: Padding(
        padding: EdgeInsets.only(top: 40),
        child: ListView.builder(
          controller: _scrollControl,
          itemCount: selectedItems.length,
          itemBuilder: (c, i) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                flex: 4,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedItems[selectedItems.keys.elementAt(i)] =
                            !selectedItems[selectedItems.keys.elementAt(i)];
                      });
                      saveSave();
                    },
                    child: Text(
                      selectedItems.keys.elementAt(i) == GameType.TRUTH
                          ? "truthOrDare".tr()
                          : gameTypeToGameTypeClass(
                                  selectedItems.keys.elementAt(i))
                              .translatedTitle,
                      style: GoogleFonts.nunito(
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 25)),
                    )),
              ),
              Expanded(
                flex: 1,
                child: Transform.scale(
                    scale: 2,
                    child: Checkbox(
                      value: selectedItems[selectedItems.keys.elementAt(i)],
                      focusColor: Colors.black,
                      checkColor: Colors.black,
                      activeColor: Colors.deepOrange,
                      onChanged: !this.itemActivated.values.elementAt(i)
                          ? null
                          : (newValue) {
                              setState(() {
                                selectedItems[selectedItems.keys.elementAt(i)] =
                                    !selectedItems[
                                        selectedItems.keys.elementAt(i)];
                              });
                              saveSave();
                            },
                    )),
              ),
            ]),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 50),
        child: GestureDetector(
          onTap: () => confirm(),
          child: Container(
            color: Color.fromRGBO(21, 21, 21, 1),
            child: Container(
              height: 80,
              width: 350.0,
              decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 8,
                      offset: Offset(2, 10), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "startGame",
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800),
                    ).tr(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

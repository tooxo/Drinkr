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
  CustomState createState() => new CustomState();
}

const String SAVED_CUSTOM_SETTING = "SAVED_CUSTOM_SETTING";

class CustomState extends State<StatefulWidget> {
  Map<GameType, bool> selectedItems = new Map();
  Map<GameType, bool> itemActivated = new Map();

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
          return new AlertDialog(
            backgroundColor: Colors.deepOrange,
            title: Text("customNoGameSelected",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(color: Colors.black),
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                )).tr(),
            content: Text(
              "customNoGameSelectedDescription",
              style: GoogleFonts.caveatBrush(
                textStyle: TextStyle(color: Colors.black),
                fontSize: 25,
              ),
            ).tr(),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text(
                  "close",
                  style: GoogleFonts.caveatBrush(
                      color: Colors.black, fontSize: 20),
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

  ScrollController _scrollControl = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor:   Color.fromRGBO(255, 111, 0, 1),
          iconTheme: IconThemeData(color: Colors.black),
          title: Center(
            child: Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: Text(
                "customTitle",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w600),
                ),
              ).tr(),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, c) {
            double calcDegree =
                (atan((c.maxHeight * 0.5 * 0.1) / c.maxWidth) * 180) / pi;
            double distanceOffset =
                (c.maxWidth * sin((calcDegree * pi / 180))) /
                    sin(((90 - calcDegree) * pi) / 180);

            return ColumnSuper(
              innerDistance: distanceOffset * -1 + 3,
              children: <Widget>[
                CustomPaint(
                  painter:
                      TopPainter(calcDegree, Color.fromRGBO(255, 111, 0, 1)),
                  child: Container(
                    height: c.maxHeight * 0.05,
                    width: c.maxWidth,
                  ),
                ),
                CustomPaint(
                  painter: MiddlePainter(calcDegree, Colors.deepOrange),
                  child: Container(
                    height: c.maxHeight * 0.85 - 6,
                    width: c.maxWidth,
                    child: ClipPath(
                      clipper: MiddleClipper(calcDegree),
                      child: DraggableScrollbar.rrect(
                        alwaysVisibleScrollThumb: true,
                        backgroundColor: Colors.black,
                        controller: _scrollControl,
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                              top: distanceOffset, bottom: distanceOffset),
                          controller: _scrollControl,
                          itemCount: selectedItems.length,
                          itemBuilder: (c, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedItems[selectedItems.keys
                                                    .elementAt(i)] =
                                                !selectedItems[selectedItems
                                                    .keys
                                                    .elementAt(i)];
                                          });
                                          saveSave();
                                        },
                                        child: new Text(
                                          selectedItems.keys.elementAt(i) ==
                                                  GameType.TRUTH
                                              ? "truthOrDare".tr()
                                              : gameTypeToGameTypeClass(
                                                      selectedItems.keys
                                                          .elementAt(i))
                                                  .translatedTitle,
                                          style: GoogleFonts.caveatBrush(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 30)),
                                        )),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Transform.scale(
                                        scale: 2,
                                        child: Checkbox(
                                          value: selectedItems[
                                              selectedItems.keys.elementAt(i)],
                                          checkColor: Colors.black,
                                          focusColor:
                                              Color.fromRGBO(255, 111, 0, 1),
                                          activeColor:
                                              Color.fromRGBO(255, 111, 0, 1),
                                          onChanged: !this
                                                  .itemActivated
                                                  .values
                                                  .elementAt(i)
                                              ? null
                                              : (newValue) {
                                                  setState(() {
                                                    selectedItems[selectedItems
                                                            .keys
                                                            .elementAt(i)] =
                                                        !selectedItems[
                                                            selectedItems.keys
                                                                .elementAt(i)];
                                                  });
                                                  saveSave();
                                                },
                                        )),
                                  )
                                ]),
                          ),
                          /* Container(
                              height: distanceOffset,
                            );*/
                        ),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter:
                      BottomPainter(calcDegree, Color.fromRGBO(255, 111, 0, 1)),
                  child: Container(
                    width: c.maxWidth,
                    height: c.maxHeight * 0.2,
                    child: Material(
                      color: Colors.transparent,
                      shape: BottomShapePainter(0, calcDegree),
                      child: InkWell(
                        customBorder: BottomShapePainter(0, calcDegree),
                        onTap: confirm,
                        child: Container(
                            margin: EdgeInsets.only(top: distanceOffset),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16.0, left: 16.0, right: 16.0),
                                child: Text(
                                  "startGame",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.caveatBrush(fontSize: 80),
                                ).tr(),
                              ),
                            )),
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ));
  }
}

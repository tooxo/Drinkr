import 'dart:math';

import 'package:Drinkr/utils/networking.dart';
import 'package:Drinkr/utils/shapes.dart';
import 'package:Drinkr/utils/spotify_api.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/file.dart';
import '../utils/types.dart';

class WordCustomization extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => WordCustomizationState();
}

class WordCustomizationState extends State<WordCustomization> {
  Map<GameType, List<String>> textsToDisplay =
      Map<GameType, List<String>>();
  bool init = false;
  List<GameType> enabledGameTypes = GameType.values;

  void reloadTexts() async {
    for (GameType type in GameType.values) {
      Iterable<String> locals = (await getLocalFiles(type))
          .where((element) => element != "")
          .toList();

      /*if (gameTypeToGameTypeClass(type).hasSolution) {
        locals = locals.map((e) {
          if (e.contains(";")) {
            return e.split(";")[0];
          }
          return e;
        }).toList();
      }*/
      if (locals.isNotEmpty) {
        textsToDisplay[type] = locals.toList();
      }
    }
    init = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      // Init the texts to display
      this.reloadTexts();
    });
  }

  void deleteItem(GameType type, String entry) async {
    textsToDisplay[type].remove(entry);
    if (textsToDisplay[type].isEmpty) {
      textsToDisplay.remove(type);
    }
    await removeCustomLines([entry], type);
    setState(() {});
  }

  Color getColor({reverse = false}) {
    if (reverse) {
      for (GameType type in textsToDisplay.keys.toList().reversed) {
        if (textsToDisplay[type].isNotEmpty) {
          return gameTypeToGameTypeClass(type).primaryColor;
        }
      }
    } else {
      for (GameType type in textsToDisplay.keys.toList()) {
        if (textsToDisplay[type].isNotEmpty) {
          return gameTypeToGameTypeClass(type).primaryColor;
        }
      }
    }
    return Colors.transparent;
  }

  String dropdownValue = gameTypeToGameTypeClass(GameType.QUIZ).translatedTitle;
  String tf1Value = "";
  String tf2Value = "";

  final _formKeyBig = GlobalKey<FormState>();
  final _formKeyField1 = GlobalKey<FormState>();
  final _formKeyField2 = GlobalKey<FormState>();

  bool buttonEnabled = true;
  IconData buttonIcon = Icons.add;

  GameType getSelectedType() {
    return GameType.values
        .where((element) =>
            gameTypeToGameTypeClass(element).translatedTitle == dropdownValue)
        .toList()[0];
  }

  Future<bool> spotifyCheckerWrapper() async {
    if (getSelectedType() == GameType.GUESS_THE_SONG) {
      if (!(await checkConnection())) {
        return true;
      }
      if (await Spotify.playlistExists(tf1Value)) {
        return true;
      } else {
        await Fluttertoast.showToast(
            msg:
                "spotifyGenericError".tr());
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 111, 0, 1),
        title: Center(
          child: Padding(
            padding: EdgeInsets.only(right: 50.0),
            child: Text(
              "customQuestions",
              style: GoogleFonts.caveatBrush(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.w600),
              ),
            ).tr(),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, c) {
          double calcDegree =
              (atan((c.maxHeight * 0.5 * 0.1) / c.maxWidth) * 180) / pi;
          double distanceOffset = (c.maxWidth * sin((calcDegree * pi / 180))) /
              sin(((90 - calcDegree) * pi) / 180);
          return ColumnSuper(
            innerDistance: distanceOffset * -1 + 3,
            children: <Widget>[
              CustomPaint(
                painter: TopPainter(calcDegree, Color.fromRGBO(255, 111, 0, 1)),
                child: Container(
                  height: 0.05 * c.maxHeight,
                  width: c.maxWidth,
                ),
              ),
              CustomPaint(
                painter: BottomPainter(calcDegree, Color.fromRGBO(255, 111, 0, 1)),
                child: Container(
                  height: 0.95 * c.maxHeight + distanceOffset - 3,
                  width: c.maxWidth,
                  child: SizedBox(
                    height: 0.95 * c.maxHeight + distanceOffset - 3,
                    width: c.maxWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            child: !init
                                ? Center(
                                    child: SpinKitFadingCircle(
                                      color: Colors.black,
                                    ),
                                  )
                                : textsToDisplay.isEmpty
                                    ? Text(
                                        "noCustomTexts",
                                        style: GoogleFonts.caveatBrush(
                                            fontSize: 30),
                                      ).tr()
                                    : Container(
                                        height: 0.95 * c.maxHeight +
                                            distanceOffset -
                                            3,
                                        width: c.maxWidth,
                                        child: ClipPath(
                                          clipper: BottomClipper(calcDegree),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  color: getColor(),
                                                  height: distanceOffset,
                                                ),
                                                for (GameType type
                                                    in textsToDisplay.keys)
                                                  textsToDisplay[type].isNotEmpty
                                                      ? Container(
                                                          width: c.maxWidth,
                                                          color:
                                                              gameTypeToGameTypeClass(
                                                                      type)
                                                                  .primaryColor,
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  width: c
                                                                      .maxWidth,
                                                                  child: Text(
                                                                    gameTypeToGameTypeClass(
                                                                            type)
                                                                        .translatedTitle,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: GoogleFonts.caveatBrush(
                                                                        fontSize:
                                                                            60),
                                                                  ),
                                                                ),
                                                                for (String value
                                                                    in textsToDisplay[
                                                                        type])
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left:
                                                                            16,
                                                                        bottom:
                                                                            5),
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                            flex:
                                                                                8,
                                                                            child:
                                                                                SingleChildScrollView(
                                                                              scrollDirection: Axis.horizontal,
                                                                              child: Text(
                                                                                gameTypeToGameTypeClass(type).hasSolution ? value.contains(";") ? value.split(";")[0] : value : value,
                                                                                textAlign: TextAlign.start,
                                                                                style: GoogleFonts.caveatBrush(fontSize: 30),
                                                                              ),
                                                                            )),
                                                                        Expanded(
                                                                            flex:
                                                                                2,
                                                                            child: Material(
                                                                                color: Colors.transparent,
                                                                                child: Center(
                                                                                    child: IconButton(
                                                                                  onPressed: () => this.deleteItem(type, value),
                                                                                  splashColor: Colors.blue,
                                                                                  highlightColor: Colors.blue,
                                                                                  icon: Icon(Icons.delete),
                                                                                  tooltip: "delete".tr(),
                                                                                ))))
                                                                      ],
                                                                    ),
                                                                  ),
                                                                Divider(
                                                                  color: Colors
                                                                      .transparent,
                                                                )
                                                              ]))
                                                      : Container(),
                                                Container(
                                                    height: distanceOffset * 2,
                                                    color: getColor(
                                                        reverse: true)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        onPressed: () => showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                backgroundColor: Colors.deepOrange,
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) =>
                      SingleChildScrollView(
                    child: Container(
                      height: 400,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Form(
                                key: _formKeyBig,
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "add",
                                      style:
                                          GoogleFonts.caveatBrush(fontSize: 40),
                                    ).tr(),
                                    Divider(
                                      thickness: 2,
                                    ),
                                    Form(
                                      key: _formKeyField1,
                                      child: TextFormField(
                                        style: GoogleFonts.caveatBrush(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        validator: (txt) {
                                          if (getSelectedType() ==
                                              GameType.GUESS_THE_SONG) {
                                            Spotify.getIdFromUrl(txt) == null
                                                // ignore: unnecessary_statements
                                                ? "invalidUrl".tr()
                                                // ignore: unnecessary_statements
                                                : null;
                                          }
                                          return txt.isEmpty
                                              ? "required".tr()
                                              : null;
                                        },
                                        decoration: InputDecoration(
                                            hintText: gameTypeToGameTypeClass(
                                                    getSelectedType())
                                                .text1),
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 3,
                                        maxLength: 250,
                                        maxLengthEnforced: true,
                                        onChanged: (newVal) {
                                          tf1Value = newVal;
                                          _formKeyField1.currentState
                                              .validate();
                                        },
                                      ),
                                    ),
                                    Divider(),
                                    Form(
                                      key: _formKeyField2,
                                      child: TextFormField(
                                        style: GoogleFonts.caveatBrush(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        validator: (txt) {
                                          if (!gameTypeToGameTypeClass(
                                                  getSelectedType())
                                              .hasSolution) {
                                            return null;
                                          }
                                          return txt.isEmpty
                                              ? "required".tr()
                                              : null;
                                        },
                                        decoration: InputDecoration(
                                            hintText: gameTypeToGameTypeClass(
                                                    getSelectedType())
                                                .text2),
                                        enabled: gameTypeToGameTypeClass(
                                                getSelectedType())
                                            .hasSolution,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 3,
                                        maxLength: 60,
                                        maxLengthEnforced: true,
                                        onChanged: (newVal) {
                                          tf2Value = newVal;
                                          _formKeyField2.currentState
                                              .validate();
                                        },
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      items: <String>[
                                        for (GameType type in GameType.values
                                            .where((element) =>
                                                element != GameType.UNDEFINED))
                                          gameTypeToGameTypeClass(type)
                                              .translatedTitle
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.caveatBrush(
                                                color: Colors.black),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        dropdownValue = newValue;
                                        setState(() {});
                                      },
                                      dropdownColor: Colors.deepOrange,
                                      value: dropdownValue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: FlatButton.icon(
                                      label:
                                          Text(buttonEnabled ? "add" : "wait")
                                              .tr(),
                                      icon: Icon(buttonEnabled
                                          ? Icons.add
                                          : Icons.cached),
                                      onPressed: this.buttonEnabled
                                          ? () async {
                                              if (getSelectedType() ==
                                                  GameType.GUESS_THE_SONG) {
                                                this.buttonEnabled = false;
                                              }
                                              if (_formKeyBig.currentState
                                                      .validate() &&
                                                  _formKeyField1.currentState
                                                      .validate() &&
                                                  _formKeyField2.currentState
                                                      .validate() &&
                                                  await spotifyCheckerWrapper()) {
                                                String thingToAppend = tf1Value;

                                                if (tf2Value.isNotEmpty &&
                                                    gameTypeToGameTypeClass(
                                                            getSelectedType())
                                                        .hasSolution) {
                                                  thingToAppend += ";$tf2Value";
                                                }

                                                await appendCustomLines(
                                                    [thingToAppend],
                                                    getSelectedType());

                                                Navigator.of(context).pop(true);
                                                this.reloadTexts();
                                              }
                                              buttonEnabled = true;
                                            }
                                          : null),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ).build(context);
            }),
      ),
    );
  }
}

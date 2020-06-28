import 'dart:math';
import 'dart:ui';

import 'package:SaufApp/difficulty.dart';
import 'package:SaufApp/shapes.dart';
import 'package:SaufApp/types.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'player.dart';

class NameSelect extends StatefulWidget {
  final List<GameType> enabledGames;

  NameSelect(this.enabledGames);

  final Color primaryColor = Color.fromRGBO(255, 81, 0, 1);
  final Color secondaryColor = Color.fromRGBO(255, 111, 0, 1);

  @override
  State<StatefulWidget> createState() => new NameSelectState();
}

class NameSelectState extends State<NameSelect> {
  String player1 = "";
  List<Player> players = new List<Player>();
  TextEditingController textEditingController = new TextEditingController();
  double sliderState = 100;
  double maxRounds = 1000;
  int divisions = 1;

  static const PREFS_PLAYERS = "PLAYER_STORE";

  Future<void> loadPlayers() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> playerNames = preferences.getStringList(PREFS_PLAYERS);
    if (playerNames == null) {
      return;
    }
    for (String name in playerNames) {
      this.players.add(Player(name));
    }
    setState(() {});
  }

  Future<void> setPlayers() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> playerNames = new List<String>();
    for (Player p in this.players) {
      playerNames.add(p.toString());
    }
    await preferences.setStringList(PREFS_PLAYERS, playerNames);
  }

  @override
  void initState() {
    super.initState();
    loadPlayers();
  }

  static String illegalNames =
      r"^ +$"; //only backspaces = illegal wie Minderheiten

  RegExp regExp = new RegExp(illegalNames);

  void buttonPress() {
    if (this.player1.isNotEmpty) {
      if (regExp.hasMatch(this.player1)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              backgroundColor: Colors.deepOrange,
              title: Text("illegalName",
                  style: GoogleFonts.caveatBrush(
                    textStyle: TextStyle(color: Colors.black),
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  )).tr(),
              content: Text(
                "illegalNameDescription",
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
        return;
      }
      if (this.players.contains(Player(this.player1))) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
              backgroundColor: Colors.deepOrange,
              title: Text("duplicatedNameTitle",
                  style: GoogleFonts.caveatBrush(
                    textStyle: TextStyle(color: Colors.black),
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  )).tr(),
              content: Text(
                "duplicatedNameDescription",
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
        return;
      }
      this.players.add(new Player(this.player1));
      this.textEditingController.clear();
      this.player1 = "";
      setPlayers();
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: widget.secondaryColor,
          iconTheme: IconThemeData(color: Colors.black),
          title: Center(
            child: Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: Text(
                "nameSelectTitle",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w600),
                ),
              ).tr(),
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(builder: (context, c) {
          double calcDegree =
              (atan((c.maxHeight * 0.5 * 0.1) / c.maxWidth) * 180) / pi;
          double distanceOffset = (c.maxWidth * sin((calcDegree * pi / 180))) /
              sin(((90 - calcDegree) * pi) / 180);

          return ColumnSuper(
            innerDistance: distanceOffset * -1 + 3,
            separatorOnTop: true,
            children: <Widget>[
              CustomPaint(
                painter: TopPainter(calcDegree, widget.secondaryColor),
                child: Container(
                  width: c.maxWidth,
                  height: c.maxHeight * 0.25,
                  child: Stack(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: TextField(
                            controller: this.textEditingController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) => {this.buttonPress()},
                            onChanged: (value) => {this.player1 = value},
                            maxLength: 15,
                            style: GoogleFonts.caveatBrush(
                              fontSize: 20,
                            ),
                            cursorColor: Colors.black,
                            decoration: InputDecoration(
                              fillColor: Colors.black,
                              hintText: "nameInput".tr(),
                              hintStyle: GoogleFonts.caveatBrush(
                                fontSize: 20,
                              ),
                              enabledBorder: new UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              focusedBorder: new UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              suffixIcon: Transform.scale(
                                scale: 0.9,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(1000)),
                                    color: Colors.transparent,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 30,
                                    ),
                                    focusColor: Colors.black,
                                    color: Colors.black,
                                    onPressed: () => {this.buttonPress()},
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Text(
                          players.length.toString() + " / 12",
                          style: GoogleFonts.caveatBrush(
                              fontSize: 25,
                              color: players.length > 12
                                  ? Colors.red.shade900
                                  : Colors.black),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              CustomPaint(
                painter: MiddlePainter(calcDegree, widget.primaryColor),
                child: Container(
                  width: c.maxWidth,
                  height: c.maxHeight * 0.65 - 6,
                  child: ClipPath(
                    clipper: MiddleClipper(calcDegree),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: distanceOffset,
                          ),
                          for (Player i in this.players)
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 0, 35, 0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: Text(
                                      i.name,
                                      style:
                                          GoogleFonts.caveatBrush(fontSize: 30),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            this.players.remove(Player(i.name));
                                            setPlayers();
                                          });
                                        },
                                        color: Colors.black,
                                        highlightColor: Colors.black,
                                        splashColor: Colors.blue,
                                        icon: Icon(Icons.delete_forever),
                                        alignment: Alignment.center,
                                      ))
                                ],
                              ),
                            ),
                          Container(
                            height: distanceOffset,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              CustomPaint(
                painter: BottomPainter(calcDegree, widget.secondaryColor),
                child: Container(
                  width: c.maxWidth,
                  height: c.maxHeight * 0.2,
                  child: Container(
                    child: Material(
                      color: Colors.transparent,
                      shape: BottomShapePainter(0, calcDegree),
                      child: InkWell(
                        customBorder: BottomShapePainter(0, calcDegree),
                        onTap: () {
                          if (players.length < 2) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                  backgroundColor: Colors.deepOrange,
                                  title: Text("nameTooFewPlayers",
                                      style: GoogleFonts.caveatBrush(
                                        textStyle:
                                            TextStyle(color: Colors.black),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 30,
                                      )).tr(),
                                  content: Text(
                                    "nameTooFewPlayersDescription",
                                    style: GoogleFonts.caveatBrush(
                                      textStyle: TextStyle(color: Colors.black),
                                      fontSize: 25,
                                    ),
                                  ).tr(),
                                  actions: <Widget>[
                                    // usually buttons at the bottom of the dialog
                                    FlatButton(
                                      child: new Text(
                                        "close".tr(),
                                        style: GoogleFonts.caveatBrush(
                                            color: Colors.black, fontSize: 20),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else if (players.length > 12) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return new AlertDialog(
                                  backgroundColor: Colors.deepOrange,
                                  title: Text("nameTooManyPlayers",
                                      style: GoogleFonts.caveatBrush(
                                        textStyle:
                                            TextStyle(color: Colors.black),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 30,
                                      )).tr(),
                                  content: Text(
                                    "nameTooManyPlayersDescriptions".tr(),
                                    style: GoogleFonts.caveatBrush(
                                      textStyle: TextStyle(color: Colors.black),
                                      fontSize: 25,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    // usually buttons at the bottom of the dialog
                                    FlatButton(
                                      child: new Text(
                                        "close",
                                        style: GoogleFonts.caveatBrush(
                                            fontSize: 20, color: Colors.black),
                                      ).tr(),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Difficulty(
                                    this.players,
                                    this.sliderState == 0
                                        ? 1
                                        : this.sliderState.toInt(),
                                    widget.enabledGames)));
                          }
                        },
                        child: Container(
                            margin: EdgeInsets.only(top: distanceOffset),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16.0,
                                    left: 16.0,
                                    right: 16.0,
                                    top: 16),
                                child: Text(
                                  "selectDifficulty",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.caveatBrush(fontSize: 80),
                                ).tr(),
                              ),
                            )),
                      ),
                    ),
                  ),
                ),
              )
            ],
          );
        }));
  }
}

import 'dart:ui';

import 'package:Drinkr/menus/game_mode.dart';
import 'package:Drinkr/widgets/name_select_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/player.dart';

class NameSelect extends StatefulWidget {
  final Color primaryColor = Color.fromRGBO(255, 81, 0, 1);
  final Color secondaryColor = Color.fromRGBO(255, 111, 0, 1);

  @override
  State<StatefulWidget> createState() => NameSelectState();
}

class NameSelectState extends State<NameSelect> {
  String player1 = "";
  List<Player> players = [];
  TextEditingController textEditingController = TextEditingController();
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
    List<String> playerNames = <String>[];
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

  RegExp regExp = RegExp(illegalNames);

  void buttonPress() {
    if (this.player1.isNotEmpty) {
      if (regExp.hasMatch(this.player1)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
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
                TextButton(
                  child: Text(
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
      this.players.add(Player(this.player1));
      this.textEditingController.clear();
      this.player1 = "";
      setPlayers();
      setState(() {});
    }
  }

  void confirm() {
    if (players.length < 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.deepOrange,
            title: Text("nameTooFewPlayers",
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(color: Colors.white),
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                )).tr(),
            content: Text(
              "nameTooFewPlayersDescription",
              style: GoogleFonts.nunito(
                textStyle: TextStyle(color: Colors.white),
                fontSize: 25,
              ),
            ).tr(),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                child: Text(
                  "close".tr(),
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 20),
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
          return AlertDialog(
            backgroundColor: Colors.deepOrange,
            title: Text("nameTooManyPlayers",
                style: GoogleFonts.nunito(
                  textStyle: TextStyle(color: Colors.white),
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                )).tr(),
            content: Text(
              "nameTooManyPlayersDescriptions".tr(),
              style: GoogleFonts.nunito(
                textStyle: TextStyle(color: Colors.white),
                fontSize: 25,
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                child: Text(
                  "close",
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    color: Colors.white,
                  ),
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
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => GameMode(players)));
    }
  }

  ScrollController scrollController = ScrollController();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 12),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image(
                          image: NetworkImage(
                            "https://raw.githubusercontent.com/tooxo/SaufAppFlutter/769d1fb5ea9496eedf11f8803ba47064493b6f9e/assets/image/AppIcon.png",
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 8,
                                offset:
                                    Offset(2, 10), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                controller: this.textEditingController,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (value) => {this.buttonPress()},
                                onChanged: (value) => {this.player1 = value},
                                style: GoogleFonts.nunito(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  hintText: "nameInput".tr(),
                                  hintStyle: GoogleFonts.nunito(
                                    fontSize: 20,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                  // contentPadding: EdgeInsets.all(0),
                                  alignLabelWithHint: true,
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      size: 45,
                                    ),
                                    focusColor: Colors.white,
                                    color: Colors.white,
                                    onPressed: () => {this.buttonPress()},
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: RawScrollbar(
                    thumbColor: Colors.deepOrange,
                    thickness: 4,
                    controller: scrollController,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          for (int i = 0; i < players.length; i += 2)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: NameSelectTile(
                                        playerName: players[i].name,
                                        deleteFunc: () {
                                          setState(() {
                                            this.players.remove(
                                                  Player(players[i].name),
                                                );
                                            setPlayers();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 16),
                                      child: i + 1 < players.length
                                          ? NameSelectTile(
                                              playerName: players[i + 1].name,
                                              deleteFunc: () {
                                                setState(() {
                                                  this.players.remove(
                                                      Player(players[i].name));
                                                  setPlayers();
                                                });
                                              },
                                            )
                                          : Container(),
                                    ),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        players.length.toString(),
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(),
                            flex: 2,
                          ),
                          Expanded(
                            flex: 6,
                            child: MaterialButton(
                              onPressed: confirm,
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Start",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                            flex: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

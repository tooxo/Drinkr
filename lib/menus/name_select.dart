import 'dart:math';
import 'dart:ui';

import 'package:Drinkr/menus/difficulty.dart';
import 'package:Drinkr/utils/shapes.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/player.dart';

class NameSelect extends StatefulWidget {
  final List<GameType> enabledGames;

  NameSelect(this.enabledGames);

  final Color primaryColor = Color.fromRGBO(255, 81, 0, 1);
  final Color secondaryColor = Color.fromRGBO(255, 111, 0, 1);

  @override
  State<StatefulWidget> createState() => NameSelectState();
}

class NameSelectState extends State<NameSelect> {
  String player1 = "";
  List<Player> players = List<Player>();
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
    List<String> playerNames = List<String>();
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
                FlatButton(
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

  //TODO: Bro do this shit gotchu ma n....!!!!

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      ),
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 60,
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                Center(
                  child: TextField(
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
                      border: InputBorder.none,
                      suffixIcon: Transform.scale(
                        scale: 0.9,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(1000)),
                            color: Colors.transparent,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add,
                              size: 30,
                            ),
                            focusColor: Colors.white,
                            color: Colors.white,
                            onPressed: () => {this.buttonPress()},
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:Drinkr/menus/game_mode.dart';
import 'package:Drinkr/menus/setting.dart';
import 'package:Drinkr/widgets/custom_alert.dart';
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
    List<String>? playerNames = preferences.getStringList(PREFS_PLAYERS);
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
          builder: (BuildContext c) => CustomAlert(
            titleTranslationKey: "illegalName",
            textTranslationKey: "illegalNameDescription",
            buttonTextTranslationKey: "close",
            backgroundColor: Color.fromRGBO(255, 92, 0, 1),
          ),
        );
      } else {
        Player newPlayer = Player(this.player1.trim());
        if (this.players.contains(newPlayer)) {
          showDialog(
            context: context,
            builder: (BuildContext c) => CustomAlert(
              titleTranslationKey: "duplicatedNameTitle",
              textTranslationKey: "duplicatedNameDescription",
              buttonTextTranslationKey: "close",
              backgroundColor: Color.fromRGBO(255, 92, 0, 1),
            ),
          );
        } else {
          this.players.add(newPlayer);
          this.textEditingController.clear();
          this.player1 = "";
          setPlayers();
          setState(() {});
        }
      }
    }
  }

  void confirm() {
    if (players.length < 2) {
      showDialog(
        context: context,
        builder: (BuildContext c) => CustomAlert(
          titleTranslationKey: "nameTooFewPlayers",
          textTranslationKey: "nameTooFewPlayersDescription",
          backgroundColor: Color.fromRGBO(255, 92, 0, 1),
          buttonTextTranslationKey: "close",
        ),
      );
    } else if (players.length > 12) {
      showDialog(
        context: context,
        builder: (BuildContext c) => CustomAlert(
          titleTranslationKey: "nameTooManyPlayers",
          textTranslationKey: "nameTooManyPlayersDescription",
          buttonTextTranslationKey: "color",
          backgroundColor: Color.fromRGBO(255, 92, 0, 1),
        ),
      );
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => GameMode(players)));
    }
  }

  void onNameChange(int playerId, String newName) {
    if (newName.isEmpty) return;
    players[playerId].name = newName;
  }

  ScrollController scrollController = ScrollController();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Column(
              children: [
                Container(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(35),
                              ),
                              child: Image.asset(
                                "assets/image/appicon3.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 92, 0, 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 8,
                                    offset: Offset(
                                        2, 10), // changes position of shadow
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
                                    onSubmitted: (value) =>
                                        {this.buttonPress()},
                                    onChanged: (value) =>
                                        {this.player1 = value},
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
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: RawScrollbar(
                      thumbColor: Color.fromRGBO(255, 92, 0, 1),
                      thickness: 4,
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                            playerId: i,
                                            changeFunc: this.onNameChange,
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
                                                  playerName:
                                                      players[i + 1].name,
                                                  playerId: i + 1,
                                                  changeFunc: this.onNameChange,
                                                  deleteFunc: () {
                                                    setState(() {
                                                      this.players.remove(
                                                          Player(players[i + 1]
                                                              .name));
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
                ),
                Divider(
                  color: Color.fromRGBO(160, 160, 160, 1),
                  thickness: 1,
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 8, top: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        players.length.toString() + " / 12",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialButton(
                            minWidth: 200,
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
                            color: Color.fromRGBO(255, 92, 0, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ],
                      ),
                    ],
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

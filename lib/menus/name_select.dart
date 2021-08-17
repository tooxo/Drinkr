import 'dart:ui';

import 'package:drinkr/menus/game_mode.dart';
import 'package:drinkr/menus/setting.dart';
import 'package:drinkr/utils/spotify_storage.dart';
import 'package:drinkr/widgets/custom_alert.dart';
import 'package:drinkr/widgets/external/animated_grid.dart';
import 'package:drinkr/widgets/language_dropdown.dart';
import 'package:drinkr/widgets/name_select_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/player.dart';

class NameSelect extends StatefulWidget {
  /*final Color primaryColor = Color.fromRGBO(0xd2, 0x6d, 0x00, 1);*/
  // final Color secondaryColor = Color.fromRGBO(0xf2, 0xac, 0x40, 1);

  final Color primaryColor = Color.fromRGBO(0xff, 0x90, 0x25, .9);
  final Color secondaryColor = Color.fromRGBO(0xff, 0x90, 0x25, 1);

  // final Color primaryColor = Color.fromRGBO(0xFF,0x82,0x09, 1);

  // final Color secondaryColor = Color.fromRGBO(0xfd, 0xab, 0x73, 1);

  final Color backgroundColor = Color.fromRGBO(21, 21, 21, 1);

  @override
  State<StatefulWidget> createState() => NameSelectState();
}

class NameSelectState extends State<NameSelect> {
  String newPlayer = "";
  List<Player> players = [];

  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNodeInput = FocusNode();

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
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) => SpotifyStorage.initializePreshippedPlaylists(context),
    );
  }

  static String illegalNames = r"^ +$"; //only backspaces

  RegExp regExp = RegExp(illegalNames);

  void buttonPress() {
    if (this.newPlayer.isNotEmpty) {
      if (regExp.hasMatch(this.newPlayer)) {
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
        Player newPlayer = Player(this.newPlayer.trim());
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
          this.newPlayer = "";
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
    players[playerId].name = newName.trim();
  }

  Map<Player, Key> keys = {};

  ScrollController scrollController = ScrollController();

  Locale selectedLocale = Locale('de', 'DE');

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  height: 250,
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            LanguageDropdown(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                child: Image.asset(
                                  "assets/image/appicon3.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (a) => Settings(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          left: 16,
                          right: 16,
                        ),
                        child: AnimatedContainer(
                          height: 60,
                          decoration: BoxDecoration(
                            color: this.focusNodeInput.hasFocus
                                ? widget.secondaryColor
                                : widget.primaryColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            /*border: Border.all(
                              color: Colors.white,
                              width: 2,
                            )*/
                          ),
                          duration: Duration(milliseconds: 250),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 8,
                                ),
                                child: TextField(
                                  focusNode: focusNodeInput,
                                  controller: this.textEditingController,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (value) => {
                                    this.buttonPress(),
                                  },
                                  onChanged: (value) => {
                                    this.newPlayer = value,
                                  },
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
                child: this.players.isEmpty
                    ? Container()
                    : SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16),
                          child: AnimatedGrid(
                            itemHeight: 55,
                            columns: 2,
                            items: players,
                            curve: Curves.linear,
                            duration: Duration(milliseconds: 100),
                            keyBuilder: (Player p) {
                              if (keys.containsKey(p)) {
                                return keys[p]!;
                              }
                              keys[p] = GlobalKey();
                              return keys[p]!;
                            },
                            builder: (BuildContext context, Player player,
                                AnimatedGridDetails details) {
                              return NameSelectTile(
                                player: player,
                                onDelete: () {
                                  setState(() {
                                    players.remove(player);
                                  });
                                },
                                onNameChange: (String newName) {
                                  player.name = newName;
                                  setState(() {});
                                },
                              );
                            },
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
                padding: const EdgeInsets.only(right: 8.0, bottom: 8, top: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      players.length.toString() + " / 12",
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 16,
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
                            borderRadius: BorderRadius.circular(15),
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
    );
  }
}

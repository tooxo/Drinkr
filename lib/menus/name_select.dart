import 'dart:ui';

import 'package:drinkr/menus/game_mode.dart';
import 'package:drinkr/menus/setting.dart';
import 'package:drinkr/utils/spotify_storage.dart';
import 'package:drinkr/widgets/animated_grid_plus.dart';
import 'package:drinkr/widgets/custom_alert.dart';
import 'package:drinkr/widgets/external/animated_grid.dart';
import 'package:drinkr/widgets/name_select_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Player> players = [];

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
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameMode(players),
        ),
      );
    }
  }

  void onNameChange(int? playerId, String newName) {
    if (newName.isEmpty) {
      if (playerId != null) {
        players.removeAt(playerId);
      }
      return;
    }
    if (playerId != null) {
      // no name change occurred
      if (players[playerId].name == newName) {
        return;
      }
    }

    Player newPlayer = Player(newName);

    int i = 2;
    while (players.contains(newPlayer)) {
      newPlayer = Player(newName + " $i");
      i++;
    }

    if (playerId == null) {
      players.add(newPlayer);
    } else {
      players[playerId] = newPlayer;
    }

    setState(() {});
    setPlayers();
  }

  Map<Player, Key> keys = {};

  ScrollController scrollController = ScrollController();

  UniqueKey finalKey = UniqueKey();

  Widget build(BuildContext context) {
    double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (bottomInset != 0.0) {
      bottomInset -= 72;
      bottomInset -= 16;
      if (bottomInset < 0) {
        bottomInset = 0;
      }
    }

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: TweenAnimationBuilder(
            builder: (BuildContext c, double value, Widget? child) {
              return Transform(
                transform: Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                ).transform,
                child: child,
              );
            },
            tween: Tween(end: bottomInset * -1),
            duration: Duration(
              milliseconds: 0,
            ),
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
                              // LanguageDropdown(),
                              Container(
                                width: 48,
                              ),
                              GestureDetector(
                                onTap: () {
                                  scrollController.animateTo(400,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.linear);
                                  // scrollController.
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        30,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/image/appicon3.png",
                                      fit: BoxFit.contain,
                                    ),
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
                        Text(
                          "Drinkr.",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                        Expanded(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black,
                                  Colors.black,
                                  Colors.black,
                                  // Colors.black,
                                  Colors.transparent,
                                ],
                              ).createShader(
                                Rect.fromLTRB(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              );
                            },
                            blendMode: BlendMode.dstIn,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: AnimatedGridPlus<Player>(
                                      itemHeight: 55 + 8,
                                      columns: 2,
                                      items: players,
                                      curve: Curves.easeInOut,
                                      duration: Duration(
                                        milliseconds: 200,
                                      ),
                                      keyBuilder: (Player p) {
                                        if (keys.containsKey(p)) {
                                          return keys[p]!;
                                        }
                                        keys[p] = GlobalKey();
                                        return keys[p]!;
                                      },
                                      finalWidget: players.length >= 12
                                          ? null
                                          : NameSelectTile(
                                              player: null,
                                              onDelete: () {},
                                              onNameChange: (String newName) {},
                                              onPlayerAdd: (String newName) {
                                                onNameChange(null, newName);
                                              },
                                              key: finalKey,
                                            ),
                                      builder: (
                                        BuildContext context,
                                        Player player,
                                        AnimatedGridDetails details,
                                      ) {
                                        return NameSelectTile(
                                          player: player,
                                          onDelete: () {
                                            setState(() {
                                              players.remove(player);
                                              setPlayers();
                                            });
                                          },
                                          onPlayerAdd: (String playerName) {},
                                          onNameChange: (String newName) {
                                            int index = players.indexOf(player);
                                            if (index != 1) {
                                              onNameChange(index, newName);
                                            }
                                          },
                                        );
                                      },
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
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 32,
                    top: 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                            color: Color.fromRGBO(0xFD, 0xA5, 0x2A, 1),
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

import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:Drinkr/utils/ad.dart';
import 'package:Drinkr/games/challenges.dart';
import 'package:Drinkr/games/guess_the_song.dart';
import 'package:Drinkr/games/never_have_i_ever.dart';
import 'package:Drinkr/utils/networking.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/games/quiz.dart';
import 'package:Drinkr/menus/setting.dart';
import 'package:Drinkr/utils/spotify_api.dart';
import 'package:Drinkr/games/truth_or_dare.dart';
import 'package:Drinkr/utils/sqlite.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/games/who_would_rather.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pedantic/pedantic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../games/guessing.dart';
import '../games/opinion.dart';
import '../utils/file.dart';

class Difficulty extends StatefulWidget {
  static const int EASY = 0;
  static const int MIDDLE = 1;
  static const int HARD = 2;

  final List<Player> players;
  final int rounds;

  final List<GameType> enabledGames;

  const Difficulty(this.players, this.rounds, this.enabledGames);

  @override
  State<StatefulWidget> createState() => DifficultyState();
}

class Game {
  dynamic function;
  GameType type;

  Game(this.function, this.type);
}

class DifficultyState extends State<Difficulty> {
  int difficulty = Difficulty.EASY;
  int displayState =
  1; // 1 Difficulty Selection, 2 Loading indicator, 3 Just Orange
  List<Game> gamePlan = [];
  Map<GameType, List> texts = Map<GameType, List>();
  Map<GameType, int> maxTexts = Map<GameType, int>();

  @override
  void initState() {
    super.initState();
    filterAvailableGames();
    availableGamesBackup = availableGames.toList();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  final AdRequest targetingInfo = AdRequest(
    keywords: ["trinken", "drinking", "alkohol", "alcohol"],
    nonPersonalizedAds: false,
    testDevices: [],
  );

  BannerAd bannerAd;

  @override
  void dispose() {
    if (bannerAd != null) {
      bannerAd.dispose().then((value) => bannerAd = null);
    }
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    super.dispose();
  }

  void filterAvailableGames() {
    for (List aGame in this.availableGames.toList()) {
      if (!widget.enabledGames.contains(aGame[1])) {
        this.availableGames.remove(aGame);
      }
    }
  }

  List<List> availableGames = [
    [
          (players, difficulty, message) =>
          NeverHaveIEver(players, difficulty, message),
      GameType.NEVER_HAVE_I_EVER
    ],
    [
          (players, difficulty, message) => Quiz(players, difficulty, message),
      GameType.QUIZ
    ],
    [
          (players, difficulty, message) =>
          Opinion(players, difficulty, message),
      GameType.OPINION
    ],
    [
          (players, difficulty, message) =>
          Guessing(players, difficulty, message),
      GameType.GUESS
    ],
    [
          (players, difficulty, message) =>
          Challenges(players, difficulty, message),
      GameType.CHALLENGES
    ],
    [
          (players, difficulty, message) =>
          GuessTheSong(players, difficulty, JsonEncoder().convert(message)),
      GameType.GUESS_THE_SONG
    ],
    [
          (players, difficulty, message) =>
          TruthOrDare(players, difficulty, message),
      GameType.TRUTH
    ],
    [
          (players, difficulty, message) =>
          WhoWouldRather(players, difficulty, message),
      GameType.WHO_WOULD_RATHER
    ]
  ];

  List<List> availableGamesBackup;

  Future<void> generateNormalPlan() async {
    while (this.gamePlan.length < widget.rounds) {
      Function gameType;
      List game;
      availableGames = availableGames
          .where((element) => this.texts[element[1]].isNotEmpty)
          .toList();
      if (this.texts.isEmpty) {
        await populateTextsMap();
      }
      do {
        if (this.availableGames.isEmpty) {
          return;
        }
        dynamic aa = this
            .availableGames
            .where((element) => this.texts[element[1]].isNotEmpty)
            .toList();
        game = aa[Random.secure().nextInt(this
            .availableGames
            .where((element) => this.texts[element[1]].isNotEmpty)
            .toList()
            .length)];
        gameType = game[0];
        if (game[1] == GameType.TRUTH) {
          int count = countOccurrencesOfSpecificGameInMap(gameType);
          if (count == this.maxTexts[game[1]] ||
              count >= maxTexts[GameType.TRUTH] ||
              count >= maxTexts[GameType.DARE]) {
            gameType = null; // provoke a rerun, because no texts are remaining
            this.availableGames.remove(game);
          }
        } else {
          if (countOccurrencesOfSpecificGameInMap(gameType) ==
              this.maxTexts[game[1]]) {
            gameType = null; // provoke a rerun, because no texts are remaining
            this.availableGames.remove(game);
          }
        }
      } while ((gameType ==
          (this.gamePlan.isNotEmpty
              ? this.gamePlan[this.gamePlan.length - 1].function
              : null) &&
          this.availableGames.length > 1) ||
          gameType == null);
      this.gamePlan.add(Game(gameType, game[1]));
    }
    // this.gamePlan.shuffle(); // Reshuffle the complete plan for good measure
    // or don't
  }

  Future<List<List<String>>> buildSpotify(List<String> playlistUrls) async {
    List<List<String>> response = [];
    Spotify spotify = Spotify();
    for (String url in playlistUrls) {
      String playlistId = Spotify.getIdFromUrl(url);
      List<List<String>> playlistResponse =
      await spotify.getPlaylist(playlistId);
      for (List<String> track in playlistResponse) {
        if (!response.contains(track)) {
          response.add(track);
        }
      }
      setState(() {
        linearProgress++;
      });
    }
    return response;
  }

  Future<void> populateTextsMap() async {
    int selectedModes = (await SharedPreferences.getInstance())
        .getInt(SettingsState.SETTING_INCLUSION_OF_QUESTIONS) ??
        SettingsState.BOTH;
    availableGames = availableGamesBackup.toList();
    setState(() {
      linearMax += availableGames.length;
    });
    for (List game in availableGames) {
      GameType gameType = game[1];
      if (gameType == GameType.GUESS_THE_SONG) {
        if (await checkConnection()) {
          List<String> urls = [];
          if (selectedModes == SettingsState.ONLY_INCLUDED ||
              selectedModes == SettingsState.BOTH) {
            urls.addAll(await getIncludedFiles(gameType, context));
          }
          if (selectedModes == SettingsState.ONLY_CUSTOM ||
              selectedModes == SettingsState.BOTH) {
            urls.addAll(await getLocalFiles(gameType));
          }
          setState(() {
            linearMax += urls.length;
          });

          texts[gameType] = await buildSpotify(urls);
          SqLite database = await SqLite().open();
          Spotify spotify = Spotify();
          dynamic missingSongs =
          texts[GameType.GUESS_THE_SONG].where((e) => e.contains(null));
          texts[GameType.GUESS_THE_SONG]
              .removeWhere((element) => element.contains(null));
          missingSongs.map((e) async =>
              texts[GameType.GUESS_THE_SONG]
                  .add(await spotify.fillMissingPreviewUrls(e, database)));
        } else {
          await Fluttertoast.showToast(
              msg: "Rate den Song wurde deaktiviert, da du über keine "
                  "Internetverbindung verfügst.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM);
          this.texts[gameType] = [];
        }
        continue;
      }

      if (gameType == GameType.TRUTH) {
        texts[GameType.TRUTH] = [];
        texts[GameType.DARE] = [];

        if (selectedModes == SettingsState.ONLY_INCLUDED ||
            selectedModes == SettingsState.BOTH) {
          texts[GameType.TRUTH]
              .addAll(await getIncludedFiles(GameType.TRUTH, context));
          texts[GameType.DARE]
              .addAll(await getIncludedFiles(GameType.DARE, context));
        }
        if (selectedModes == SettingsState.ONLY_CUSTOM ||
            selectedModes == SettingsState.BOTH) {
          texts[GameType.TRUTH].addAll(await getLocalFiles(GameType.TRUTH));
          texts[GameType.DARE].addAll(await getLocalFiles(GameType.DARE));
        }
        continue;
      }

      texts[gameType] = [];
      if (selectedModes == SettingsState.ONLY_INCLUDED ||
          selectedModes == SettingsState.BOTH) {
        texts[gameType].addAll(await getIncludedFiles(gameType, context));
      }
      if (selectedModes == SettingsState.ONLY_CUSTOM ||
          selectedModes == SettingsState.BOTH) {
        texts[gameType].addAll(await getLocalFiles(gameType));
      }

      setState(() {
        linearProgress++;
      });
    }
    for (GameType gameType in texts.keys) {
      // Shuffle the items in the list
      // to prevent similar rounds from occurring
      texts[gameType].shuffle();
      maxTexts[gameType] = texts[gameType].length;
    }
    setState(() {
      linearProgress = linearMax;
    });
  }

  Future<void> fulfillNormalPlan() async {
    setState(() {
      this.displayState = 3;
    });

    bool ads = await shouldShowAds();

    if (ads) {
      AdListener listener = AdListener(onAdLoaded: (Ad ad) async {
        if (bannerAd.size.width <= context.size.width ~/ 2) {
          if (bannerAd = null) return;
          if (!mounted) {
            unawaited(bannerAd.dispose());
            bannerAd = null;
          } else {}
        }
      });
      bannerAd = BannerAd(
        adUnitId: BannerAd.testAdUnitId,
        size: AdSize.banner,
        request: targetingInfo,
        listener: listener,
      );

      bool shouldContinue = false;
      do {
        if (gamePlan.isEmpty) {
          await generateNormalPlan();
        }
        bool result;
        for (Game game in gamePlan) {
          if (texts.values
              .where((element) => element.isNotEmpty)
              .isEmpty) {
            await populateTextsMap();
          }
          dynamic randomlyChosenText;
          if (game.type == GameType.TRUTH &&
              texts[GameType.TRUTH].isNotEmpty &&
              texts[GameType.DARE].isNotEmpty) {
            String randomTextTruth = texts[GameType.TRUTH]
            [Random.secure().nextInt(texts[GameType.TRUTH].length)];

            String randomTextDare = texts[GameType.DARE]
            [Random.secure().nextInt(texts[GameType.DARE].length)];

            texts[GameType.TRUTH].remove(randomTextTruth);
            texts[GameType.DARE].remove(randomTextDare);

            randomlyChosenText =
                json.encode({"truth": randomTextTruth, "dare": randomTextDare});
          } else {
            try {
              randomlyChosenText = texts[game.type]
              [Random.secure().nextInt(texts[game.type].length)];
              texts[game.type].remove(randomlyChosenText);
            } on IndexError {
              continue;
            }
          }

          /*
        Test if the text is valid to prevent errors presenting
         */

          try {
            if (randomlyChosenText.toString().trim() == "") throw Exception();

            if (game.type == GameType.TRUTH) {
              dynamic jsonEncoded = json.decode(randomlyChosenText);
              if (!jsonEncoded.keys.contains("truth") ||
                  !jsonEncoded.keys.contains("dare")) {
                throw Exception();
              }
            }
            if (gameTypeToGameTypeClass(game.type).hasSolution) {
              String split1 = randomlyChosenText.split(";")[0];
              String split2 = randomlyChosenText.split(";")[1];

              if (split1.trim() == "" || split2.trim() == "") {
                throw Exception();
              }
            }
          } catch (exc) {
            continue;
          }

          result = await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (c, a1, a2) =>
                  game.function(widget.players, difficulty, randomlyChosenText),
              transitionsBuilder: (c, anim, a2, child) {
                if (anim.status == AnimationStatus.reverse) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.0, 0),
                      end: Offset(0.0, -1),
                    ).animate(a2),
                    child: child,
                  );
                }
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, 1.0),
                    end: Offset(0.0, 0.0),
                  ).animate(anim),
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 200),
            ),
          );

          if (result == null) {
            /*
          This shouldn't happen, this only happens, if some unexpected things
          happen inside a game, this only catches here to dispose the difficulty
          correctly and make the bannerAd disappear.
           */
            await Fluttertoast.showToast(msg: "An unexpected Error occured.");
            Navigator.of(context).pop(false);
            return;
          }
          result = result || gamePlan.isEmpty;
          if (result) {
            break;
          }
        }
        if (result == null) {
          // TODO: This occures only if a game launches without loading any texts.
          Navigator.of(context).pop(false);
          return;
        }
        if (!result) {
          await showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                      title: Text("goOnTitle",
                          style: GoogleFonts.caveatBrush(
                            textStyle: TextStyle(color: Colors.black),
                            fontWeight: FontWeight.w800,
                            fontSize: 30,
                          )).tr(),
                      content: Text(
                        "goOnDescription",
                        style: GoogleFonts.caveatBrush(
                          textStyle: TextStyle(color: Colors.black),
                          fontSize: 25,
                        ),
                      ).tr(),
                      backgroundColor: Colors.deepOrange,
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        TextButton(
                          child: Text(
                            "exit",
                            style: GoogleFonts.caveatBrush(
                                color: Colors.black, fontSize: 20),
                          ).tr(),
                          onPressed: () {
                            shouldContinue = false;
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            "goOn",
                            style: GoogleFonts.caveatBrush(
                                color: Colors.black, fontSize: 20),
                          ).tr(),
                          onPressed: () {
                            shouldContinue = true;
                            Navigator.of(context).pop();
                          },
                        ),
                      ]).build(context));
        }
      } while (shouldContinue);
      if (ads) {
        try {
          await bannerAd.dispose();
          bannerAd = null;
        } catch (_) {}
      }

      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

      this.displayState = 1;
      setState(() {});

      Navigator.of(context).pop();
    }
  }

  int countOccurrencesOfSpecificGameInMap(Function gameType) {
    int count = 0;
    for (Game game in this.gamePlan) {
      if (game.function == gameType) {
        count++;
      }
    }
    return count;
  }

  selectDifficulty(int selectedDifficulty) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    this.difficulty = selectedDifficulty;
    this.displayState = 2;
    setState(() {});
    populateTextsMap().then(
            (value) =>
            generateNormalPlan().then((value) => fulfillNormalPlan()));
  }

  int linearProgress = 1;
  int linearMax = 2;

  bool wantSchluck = true;
  bool wantShots = true;

  int startSchluck = 0;
  int endSchluck = 0;

  int startShots = 0;
  int endShots = 0;

  void incrementStartSchluck() {
    setState(() {
      startSchluck++;
    });
  }

  void decrementStartSchluck() {
    setState(() {
      startSchluck--;
    });
  }

  void incrementEndSchluck() {
    setState(() {
      endSchluck++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return displayState == 1
        ? Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        title: Text(
          "selectDifficulty",
          style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ).tr(),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  selectDifficulty(Difficulty.EASY);
                },
                child: Container(
                  height: 180,
                  width: 350.0,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 8,
                      offset: Offset(2, 10), // changes position of shadow
                    ),
                  ], borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10, left: 10),
                          child: Icon(
                            Icons.local_drink_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Leicht",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ).tr(),
                              Text(
                                "1-2 Schlücke | 5 shots",
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ).tr(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  selectDifficulty(Difficulty.MIDDLE);
                },
                child: Container(
                  height: 180,
                  width: 350.0,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 8,
                          offset:
                          Offset(2, 10), // changes position of shadow
                        ),
                      ],
                      color: Colors.grey,
                      borderRadius:
                      BorderRadius.all(Radius.circular(30))),
                  child: Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10, left: 10),
                          child: Icon(
                            Icons.local_drink_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Normal",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ).tr(),
                              Text(
                                "1-2 Schlücke | 5 shots",
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ).tr(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  selectDifficulty(Difficulty.HARD);
                },
                child: Container(
                  height: 180,
                  width: 350.0,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 8,
                      offset: Offset(2, 10), // changes position of shadow
                    ),
                  ], borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10, left: 10),
                          child: Icon(
                            Icons.local_drink_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Absturz",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ).tr(),
                              Text(
                                "1-2 Schlücke | 5 shots",
                                style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ).tr(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addCustomDifficulty(context),
        child: Icon(
          Icons.add,
          size: 25,
        ),
      ),
    )
        : Container(
      height: 20,
      color: Color.fromRGBO(21, 21, 21, 1),
      child: LinearProgressIndicator(
        value: linearProgress / linearMax,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        valueColor: const AlwaysStoppedAnimation(Colors.deepOrange),
      ),
    );
  }

  void addCustomDifficulty(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            backgroundColor: Color.fromRGBO(21, 21, 21, 1),
            title: TextField(
              style: GoogleFonts.nunito(
                fontSize: 20,
                color: Colors.white,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Name der Schwierigkeit...".tr(),
                hintStyle: GoogleFonts.nunito(
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.5),
                ),
                border: InputBorder.none,
              ),
            ),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: Checkbox(
                        value: true,
                        focusColor: Colors.white,
                        checkColor: Colors.white,
                        activeColor: Colors.deepOrange,
                      ),
                    ),
                    Text(
                      "Schlück(e)",
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(),
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ).tr(),
                    Row(
                      children: [
                        Column(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: incrementStartSchluck),
                            Text(
                              startSchluck.toString(),
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(),
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: decrementStartSchluck),
                          ],
                        ),
                        Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        Column(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: incrementStartSchluck),
                            Text(
                              startSchluck.toString(),
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(),
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: decrementStartSchluck),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 2,
                      child: Checkbox(
                        value: true,
                        focusColor: Colors.white,
                        checkColor: Colors.white,
                        activeColor: Colors.deepOrange, onChanged: (bool value) {  },
                      ),
                    ),
                    Text(
                      "Shot(s)",
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(),
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ).tr(),
                    Row(
                      children: [
                        Column(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: incrementStartSchluck),
                            Text(
                              startSchluck.toString(),
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(),
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: decrementStartSchluck),
                          ],
                        ),
                        Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        Column(
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: incrementStartSchluck),
                            Text(
                              startSchluck.toString(),
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(),
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                onPressed: decrementStartSchluck),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 50),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 50,
                      width: 350.0,
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
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Schwierigkeit auswählen",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

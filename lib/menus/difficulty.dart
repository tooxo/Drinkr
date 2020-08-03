import 'dart:convert';
import 'dart:math';
import 'package:Drinkr/utils/ad.dart';
import 'package:Drinkr/games/challenges.dart';
import 'package:Drinkr/games/guess_the_song.dart';
import 'package:Drinkr/games/never_have_i_ever.dart';
import 'package:Drinkr/utils/networking.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/games/quiz.dart';
import 'package:Drinkr/menus/setting.dart';
import 'package:Drinkr/utils/shapes.dart';
import 'package:Drinkr/utils/spotify_api.dart';
import 'package:Drinkr/games/truth_or_dare.dart';
import 'package:Drinkr/utils/sqlite.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/games/who_would_rather.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
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
  List<Game> gamePlan = List<Game>();
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

  final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      keywords: ["trinken", "drinking", "alkohol", "alcohol"],
      childDirected: false,
      nonPersonalizedAds: false,
      testDevices: []);

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
      (players, difficulty, message) => Opinion(players, difficulty, message),
      GameType.OPINION
    ],
    [
      (players, difficulty, message) => Guessing(players, difficulty, message),
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
    List<List<String>> response = List<List<String>>();
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
          missingSongs.map((e) async => texts[GameType.GUESS_THE_SONG]
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
      bannerAd = BannerAd(
          adUnitId: BannerAd.testAdUnitId,
          size: AdSize.banner,
          targetingInfo: targetingInfo);

      try {
        unawaited(bannerAd.load().then((value) async {
          /// Prevent the banner ad from overlaying on buttons
          if (bannerAd.size.width <= context.size.width ~/ 2) {
            if (bannerAd == null) {
              return;
            }
            if (!mounted) {
              unawaited(bannerAd.dispose());
              bannerAd = null;
            } else {
              await bannerAd.show(anchorOffset: 8);
              if (!mounted && bannerAd != null) {
                try {
                  unawaited(bannerAd.dispose());
                  bannerAd = null;
                } on AssertionError catch (_){}
              }
            }
          }
        }));

        /// This PlatformException is thrown when no ad was loaded
        /// so it can be simply ignored
      } on PlatformException {
        // ignored
      } catch (_) {
        // fallback for all other things that could happen while loading ads
      }
    }

    bool shouldContinue = false;
    do {
      if (gamePlan.isEmpty) {
        await generateNormalPlan();
      }
      bool result;
      for (Game game in gamePlan) {
        if (texts.values.where((element) => element.isNotEmpty).isEmpty) {
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

        result = await Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (c, a1, a2) =>
              game.function(widget.players, difficulty, randomlyChosenText),
          transitionsBuilder: (c, anim, a2, child) {
            if (anim.status == AnimationStatus.reverse) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: Offset(0.0, 0), end: Offset(0.0, -1))
                        .animate(a2),
                child: child,
              );
            }
            return SlideTransition(
              position:
                  Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset(0.0, 0.0))
                      .animate(anim),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 200),
        ));
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
            builder: (context) => AlertDialog(
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
                      FlatButton(
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
                      FlatButton(
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
        (value) => generateNormalPlan().then((value) => fulfillNormalPlan()));
  }

  int linearProgress = 1;
  int linearMax = 2;

  @override
  Widget build(BuildContext context) {
    return this.displayState == 1
        ? LayoutBuilder(
            builder: (context, c) {
              double calcDegree =
                  (atan((c.maxHeight * 0.5 * 0.1) / c.maxWidth) * 180) / pi;
              double distanceOffset =
                  (c.maxWidth * sin((calcDegree * pi / 180))) /
                      sin(((90 - calcDegree) * pi) / 180);

              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: Color.fromRGBO(255, 111, 0, 1),
                  title: Text(
                    "selectDifficulty",
                    style: GoogleFonts.caveatBrush(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w600),
                  ).tr(),
                  iconTheme: IconThemeData(color: Colors.black),
                ),
                backgroundColor: Colors.black,
                body: ColumnSuper(
                  innerDistance: distanceOffset * -1 + 3,
                  children: <Widget>[
                    CustomPaint(
                      painter: TopPainter(calcDegree, Colors.yellow),
                      child: Container(
                        height: c.maxHeight / 3 - distanceOffset / 2,
                        width: c.maxWidth,
                        child: Material(
                          color: Colors.transparent,
                          shape: TopShapePainter(calcDegree),
                          child: InkWell(
                            customBorder: TopShapePainter(calcDegree),
                            onTap: () => selectDifficulty(Difficulty.EASY),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/image/beer_easy.png",
                                      height: c.maxHeight * (1 / 6),
                                    ),
                                    Transform.rotate(
                                      angle: calcDegree * pi / 170 * -1,
                                      child: SizedBox(
                                        width: c.maxWidth * 0.66 - 16,
                                        height: c.maxHeight * 0.33 -
                                            distanceOffset * 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 3,
                                                child: FittedBox(
                                                  fit: BoxFit.fitHeight,
                                                  child: Text(
                                                    "difficultyLow",
                                                    style:
                                                        GoogleFonts.caveatBrush(
                                                            fontSize: 300),
                                                  ).tr(),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    "difficultyLowDescription",
                                                    style:
                                                        GoogleFonts.caveatBrush(
                                                            fontSize: 300),
                                                  ).tr(),
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
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: MiddlePainter(calcDegree, Colors.orange),
                      child: Container(
                        height: c.maxHeight / 3 + distanceOffset / 2 - 6,
                        width: c.maxWidth,
                        child: Material(
                          color: Colors.transparent,
                          shape: MiddleShapePainter(0, calcDegree),
                          child: InkWell(
                            onTap: () => selectDifficulty(Difficulty.MIDDLE),
                            customBorder: MiddleShapePainter(0, calcDegree),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      "assets/image/beer_middle.png",
                                      height: c.maxHeight * (1 / 6),
                                    ),
                                    Transform.rotate(
                                      angle: calcDegree * pi / 180 * -1,
                                      child: SizedBox(
                                        width: c.maxWidth * 0.66 - 16,
                                        height: c.maxHeight * 0.33 -
                                            distanceOffset * 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 3,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    "difficultyMed",
                                                    style:
                                                        GoogleFonts.caveatBrush(
                                                            fontSize: 300),
                                                  ).tr(),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    "difficultyMedDescription",
                                                    style:
                                                        GoogleFonts.caveatBrush(
                                                            fontSize: 300),
                                                  ).tr(),
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
                          ),
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: BottomPainter(calcDegree, Colors.red),
                      child: Container(
                        height: c.maxHeight / 3,
                        width: c.maxWidth,
                        child: Material(
                          color: Colors.transparent,
                          shape: BottomShapePainter(0, calcDegree),
                          child: InkWell(
                            onTap: () => selectDifficulty(Difficulty.HARD),
                            customBorder: BottomShapePainter(0, calcDegree),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        "assets/image/beer_hard.png",
                                        height: c.maxHeight * (1 / 6),
                                      ),
                                    ),
                                    Transform.rotate(
                                      angle: calcDegree * pi / 180 * -1,
                                      child: SizedBox(
                                        width: c.maxWidth * 0.63 - 20,
                                        height: c.maxHeight * 0.33 -
                                            distanceOffset * 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 3,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    "difficultyHigh",
                                                    style:
                                                        GoogleFonts.caveatBrush(
                                                            fontSize: 300),
                                                  ).tr(),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    "difficultyHighDescription",
                                                    style:
                                                        GoogleFonts.caveatBrush(
                                                            fontSize: 300),
                                                  ).tr(),
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
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          )
        : this.displayState == 2
            ? Scaffold(
                backgroundColor: Color.fromRGBO(255, 111, 0, 1),
                body: Stack(
                  children: [
                    Center(
                      child: SpinKitFadingCircle(
                        color: Colors.black,
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                "spotifyLongLoad",
                                style: GoogleFonts.caveatBrush(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ).tr(),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 12,
                              child: LinearProgressIndicator(
                                value: linearProgress / linearMax,
                                backgroundColor: Colors.yellow.shade900,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            : Container(
                color: Color.fromRGBO(255, 111, 0, 1),
              );
  }
}

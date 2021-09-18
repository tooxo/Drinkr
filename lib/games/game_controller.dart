import 'dart:convert';
import 'dart:math';

import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/menus/setting.dart';
import 'package:drinkr/utils/ad.dart';
import 'package:drinkr/utils/drinking.dart';
import 'package:drinkr/utils/file.dart';
import 'package:drinkr/utils/networking.dart';
import 'package:drinkr/utils/player.dart';
import 'package:drinkr/utils/spotify_api.dart';
import 'package:drinkr/utils/spotify_storage.dart';
import 'package:drinkr/utils/types.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pedantic/pedantic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutter/src/widgets/pages.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/file.dart';

class Game {
  dynamic function;
  GameType type;

  Game(this.function, this.type);
}

class GameController {
  final int rounds;
  final List<GameType> enabledGames;
  final List<Player> players;
  final BuildContext context;
  final bool filterAdultQuestions;

  GameController(this.rounds, this.enabledGames, this.players, this.context,
      this.filterAdultQuestions);

  final List<TypeClass<BaseType>> available_games = [
    NeverHaveIEverType(),
    QuizType(),
    OpinionType(),
    GuessingType(),
    ChallengesType(),
    GuessTheSongType(),
    TruthType(),
    WhoWouldRatherType(),
  ];

  Spotify spotify = Spotify();

  List<Game> gamePlan = [];
  Map<GameType, List> texts = Map<GameType, List>();
  Map<GameType, int> maxTexts = Map<GameType, int>();

  int countOccurrencesOfSpecificGameInMap(GameType gameType) {
    int count = 0;
    for (Game game in this.gamePlan) {
      if (game.type == gameType) {
        count++;
      }
    }
    return count;
  }

  List<Player> lastPickedPlayers = [];

  Player getRandomPlayer() {
    if (lastPickedPlayers.length == players.length) {
      lastPickedPlayers.clear();
    }

    List<Player> possiblePlayers =
        players.where((p) => !lastPickedPlayers.contains(p)).toList();

    if (possiblePlayers.isEmpty) {
      possiblePlayers = players;
    }

    Player randomPlayer =
        possiblePlayers[Random.secure().nextInt(possiblePlayers.length)];

    lastPickedPlayers.add(randomPlayer);
    return randomPlayer;
  }

  String populateText(String unpopulated, DifficultyType difficulty) {
    String raw = unpopulated.toString();
    while (raw.contains("%player")) {
      raw = raw.replaceFirst("%player", getRandomPlayer().name);
    }

    while (raw.contains("%amountshot")) {
      int amountShots = Drinking.getDrinkAmountShot(difficulty);
      if (amountShots > 1) {
        raw = raw.replaceFirst("%amountshot", "$amountShots Shots");
      } else {
        if (amountShots == 0) {
          raw = raw.replaceFirst("%amountshot", "%amountbeer");
        } else {
          raw = raw.replaceFirst("%amountshot", "$amountShots Shot");
        }
      }
    }

    while (raw.contains("%amountbeer")) {
      int amountBeer = Drinking.getDrinkAmountBeer(difficulty);
      if (amountBeer > 1) {
        raw = raw.replaceFirst("%amountbeer", "$amountBeer " + "sips".tr());
      } else {
        raw = raw.replaceFirst("%amountbeer", "$amountBeer " + "sip".tr());
      }
    }

    return raw;
  }

  Future<bool> _populateTextsMap() async {
    int selectedModes = (await SharedPreferences.getInstance())
            .getInt(SettingsState.SETTING_INCLUSION_OF_QUESTIONS) ??
        SettingsState.BOTH;
    for (GameType gameType in enabledGames) {
      if (gameType == GameType.GUESS_THE_SONG) {
        if (await checkConnection()) {
          /*List<String> urls = [];
          if (selectedModes == SettingsState.ONLY_INCLUDED ||
              selectedModes == SettingsState.BOTH) {
            urls.addAll(await getIncludedFiles(
                gameType, context, this.filterAdultQuestions));
          }
          if (selectedModes == SettingsState.ONLY_CUSTOM ||
              selectedModes == SettingsState.BOTH) {
            urls.addAll(await getLocalFiles(gameType));
          }*/
          List<String> urls = SpotifyStorage.playlists_box.values
              .where(
                (Playlist e) => e.enabled,
              )
              .map(
                (Playlist e) => e.url,
              )
              .toList();

          if (urls.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                "Rate den Song wurde deaktiviert, da alle Playlists "
                        "in den Einstellungen deaktiviert wurden."
                    .tr(),
              ),
            ));
          }

          texts[gameType] = await buildSpotify(urls, spotify);
          List<Song> missingSongs = texts[GameType.GUESS_THE_SONG]!
              .where((element) =>
                  element.name == null ||
                  element.id == null ||
                  element.previewUrl == null)
              .map((e) => e as Song)
              .toList();
          texts[GameType.GUESS_THE_SONG]!
              .removeWhere((element) => missingSongs.contains(element as Song));
          missingSongs.map((e) async => texts[GameType.GUESS_THE_SONG]!
              .add(await spotify.fillMissingPreviewUrls(e)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Rate den Song wurde deaktiviert, da du über keine "
                        "Internetverbindung verfügst."
                    .tr(),
              ),
            ),
          );
          this.texts[gameType] = [];
        }
        continue;
      }

      if (gameType == GameType.TRUTH) {
        texts[GameType.TRUTH] = [];
        texts[GameType.DARE] = [];

        if (selectedModes == SettingsState.ONLY_INCLUDED ||
            selectedModes == SettingsState.BOTH) {
          texts[GameType.TRUTH]!.addAll(await getIncludedFiles(
              GameType.TRUTH, context, this.filterAdultQuestions));
          texts[GameType.DARE]!.addAll(await getIncludedFiles(
              GameType.DARE, context, this.filterAdultQuestions));
        }
        if (selectedModes == SettingsState.ONLY_CUSTOM ||
            selectedModes == SettingsState.BOTH) {
          texts[GameType.TRUTH]!.addAll(await getLocalFiles(GameType.TRUTH));
          texts[GameType.DARE]!.addAll(await getLocalFiles(GameType.DARE));
        }
        continue;
      }

      texts[gameType] = [];
      if (selectedModes == SettingsState.ONLY_INCLUDED ||
          selectedModes == SettingsState.BOTH) {
        texts[gameType]!.addAll(await getIncludedFiles(
            gameType, context, this.filterAdultQuestions));
      }
      if (selectedModes == SettingsState.ONLY_CUSTOM ||
          selectedModes == SettingsState.BOTH) {
        texts[gameType]!.addAll(await getLocalFiles(gameType));
      }
    }
    for (GameType gameType in texts.keys) {
      // Shuffle the items in the list
      // to prevent similar rounds from occurring
      texts[gameType]!.shuffle();
      maxTexts[gameType] = texts[gameType]!.length;
    }

    int sum = texts.values
        .map((e) => e.length)
        .fold(0, (previousValue, element) => previousValue + element);
    return sum > 0;
  }

  Future<List<Song>> buildSpotify(
      List<String> playlistUrls, Spotify spotify) async {
    List<Song> response = [];

    List<Future<Playlist?>> playlistFutures = playlistUrls
        .map(Spotify.getIdFromUrl)
        .map((e) => spotify.getPlaylist(e!))
        .toList();

    List<Playlist?> playlists = await Future.wait(playlistFutures);

    for (Playlist? p in playlists) {
      if (p == null) {
        continue;
      }
      for (String track_id in p.song_ids) {
        Song? track = await SpotifyStorage.getFromSpotifyCache(track_id);
        if (track != null) {
          if (!response.contains(track)) {
            response.add(track);
          }
        }
      }
    }
    return response;
  }

  Future<bool> generateNormalPlan() async {
    List<TypeClass<BaseType>> availableGamesBackup = available_games.toList();
    while (this.gamePlan.length < rounds) {
      TypeClass<BaseType> game;
      if (this.texts.isEmpty) {
        await _populateTextsMap();
      }
      availableGamesBackup = available_games
          .where((element) =>
              enabledGames.contains(element.type) &&
              this.texts[element.type]!.isNotEmpty)
          .toList();
      GameType gameType;
      do {
        if (availableGamesBackup.isEmpty) {
          return true;
        }
        dynamic aa = availableGamesBackup
            .where((element) => this.texts[element.type]!.isNotEmpty)
            .toList();
        game = aa[Random.secure().nextInt(availableGamesBackup
            .where((element) => this.texts[element.type]!.isNotEmpty)
            .toList()
            .length)];

        gameType = game.type;
        if (game.type == GameType.TRUTH) {
          int count = countOccurrencesOfSpecificGameInMap(game.type);
          if (count == this.maxTexts[game.type] ||
              count >= maxTexts[GameType.TRUTH]! ||
              count >= maxTexts[GameType.DARE]!) {
            gameType = GameType
                .UNDEFINED; // provoke a rerun, because no texts are remaining
            availableGamesBackup.remove(game);
          }
        } else {
          if (countOccurrencesOfSpecificGameInMap(gameType) ==
              this.maxTexts[game.type]) {
            gameType = GameType
                .UNDEFINED; // provoke a rerun, because no texts are remaining
            availableGamesBackup.remove(game);
          }
        }
      } while ((gameType ==
                  (this.gamePlan.isNotEmpty
                      ? this.gamePlan[this.gamePlan.length - 1].type
                      : null) &&
              availableGamesBackup.length > 1) ||
          gameType == GameType.UNDEFINED);
      this.gamePlan.add(Game(game.constructorFunction, game.type));
    }
    return this.gamePlan.isNotEmpty;
  }

  BannerAd? bannerAd;
  OverlayEntry? adOverlayEntry;

  Future<void> _fulfillNormalPlan(DifficultyType difficulty) async {
    unawaited(SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]));
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent));
    unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []));

    bool ads = await shouldShowAds();

    if (ads) {
      BannerAdListener listener = BannerAdListener(onAdLoaded: (Ad ad) async {
        if (bannerAd == null) return;
        if (bannerAd!.size.width >= context.size!.width ~/ 2) {
          unawaited(bannerAd!.dispose());
          bannerAd = null;
        }

        // show the ad
        if (adOverlayEntry == null) {
          adOverlayEntry = OverlayEntry(builder: (BuildContext context) {
            if (bannerAd == null) return Container();
            return Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: bannerAd!.size.width.toDouble(),
                  height: 80,
                  child: Center(
                    child: AdWidget(
                      ad: bannerAd!,
                    ),
                  ),
                ),
              ),
            );
          });

          Overlay.of(context)?.insert(adOverlayEntry!);
        }
      }, onAdFailedToLoad: (Ad? ad, LoadAdError lae) {
        print("loading ad error: " + lae.message);
      });
      bannerAd = BannerAd(
        adUnitId: String.fromEnvironment(
          "BANNER_AD_ID",
          defaultValue: BannerAd.testAdUnitId,
        ),
        size: AdSize.banner,
        request: AdRequest(
          keywords: ["alkohol", "alcohol", "drinking", "beer", "liquor"],
        ),
        listener: listener,
      );
      unawaited(bannerAd!.load());
    }
    late bool shouldContinue;

    do {
      Widget? oldRoute;
      Widget? newRoute;
      shouldContinue = false;

      if (gamePlan.isEmpty) {
        await generateNormalPlan();
      }
      bool? result;
      for (Game game in gamePlan) {
        TypeClass<BaseType> typeClass = gameTypeToGameTypeClass(game.type);
        if (texts.values.where((element) => element.isNotEmpty).isEmpty) {
          await _populateTextsMap();
        }
        dynamic randomlyChosenText;
        if (game.type == GameType.TRUTH &&
            texts[GameType.TRUTH]!.isNotEmpty &&
            texts[GameType.DARE]!.isNotEmpty) {
          String randomTextTruth = texts[GameType.TRUTH]![
              Random.secure().nextInt(texts[GameType.TRUTH]!.length)];

          String randomTextDare = texts[GameType.DARE]![
              Random.secure().nextInt(texts[GameType.DARE]!.length)];

          texts[GameType.TRUTH]!.remove(randomTextTruth);
          texts[GameType.DARE]!.remove(randomTextDare);

          randomlyChosenText =
              json.encode({"truth": randomTextTruth, "dare": randomTextDare});
        } else if (game.type == GameType.GUESS_THE_SONG) {
          try {
            Song randomSong = texts[game.type]![
                Random.secure().nextInt(texts[game.type]!.length)];

            randomlyChosenText = json.encode(
                {"name": randomSong.name, "previewUrl": randomSong.previewUrl});

            texts[game.type]!.remove(randomSong);
          } on IndexError {
            continue;
          }
        } else {
          try {
            randomlyChosenText = texts[game.type]![
                Random.secure().nextInt(texts[game.type]!.length)];
            texts[game.type]!.remove(randomlyChosenText);
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
          if (typeClass.hasSolution) {
            if (!randomlyChosenText.contains(";")) {
              throw Exception("no solution in text " + randomlyChosenText);
            }
            String split1 = randomlyChosenText.split(";")[0];
            String split2 = randomlyChosenText.split(";")[1];

            if (split1.trim() == "" || split2.trim() == "") {
              throw Exception();
            }
          }
        } on Exception catch (_, exc) {
          print(exc.toString());
          continue;
        }

        Player? player;
        if (typeClass.singlePlayerActivity) {
          player = getRandomPlayer();
        } else {
          player = Player("");
        }

        if (typeClass.includesPlayers) {
          randomlyChosenText = populateText(randomlyChosenText, difficulty);
        }

        oldRoute = newRoute;
        newRoute = game.function(player, difficulty, randomlyChosenText);

        result = await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => newRoute!,
            transitionsBuilder: (BuildContext c, Animation<double> anim,
                Animation<double> a2, Widget child) {
              if (oldRoute == null) {
                return child;
              }

              return Transform.scale(
                scale: anim.value >= .5 ? 1 : 1.025 - anim.value * 0.025,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      anim.value == 1.0
                          ? Container()
                          : Opacity(
                              opacity: 1.0 - anim.value,
                              child: oldRoute,
                            ),
                      Opacity(
                        opacity: anim.value,
                        child: child,
                      ),
                    ],
                  ),
                ),
              );
            },
            transitionDuration: Duration(
              milliseconds: 500,
            ),
            // reverseTransitionDuration: Duration.zero,
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
          break;
        }
        result = result || gamePlan.isEmpty;
        if (result) {
          break;
        }
      }
      if (result == null) {
        // TODO: This occures only if a game launches without loading any texts.
        Navigator.of(context).pop(false);
        break;
      }
      if (!result) {
        if (ads) {
          adOverlayEntry?.remove();
        }

        unawaited(showFullscreenAd(context));

        await showDialog(
          context: context,
          builder: (context) => Container(
            color: Colors.black,
            child: AlertDialog(
                title: Text(
                  "goOnTitle",
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  ),
                ).tr(),
                content: Text(
                  "goOnDescription",
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ).tr(),
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  TextButton(
                    child: Text(
                      "exit",
                      style:
                          GoogleFonts.nunito(color: Colors.white, fontSize: 20),
                    ).tr(),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      "goOn",
                      style:
                          GoogleFonts.nunito(color: Colors.white, fontSize: 20),
                    ).tr(),
                    onPressed: () {
                      shouldContinue = true;
                      Navigator.of(context).pop();
                    },
                  ),
                ]).build(context),
          ),
        );
        if (adOverlayEntry != null && shouldContinue) {
          Overlay.of(context)?.insert(adOverlayEntry!);
        }
      }
    } while (shouldContinue);

    if (ads) {
      try {
        adOverlayEntry?.dispose();
        adOverlayEntry = null;

        await bannerAd?.dispose();
        bannerAd = null;
      } catch (_) {}
    }

    unawaited(
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      ),
    );

    unawaited(
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values),
    );
  }

  Future<bool> prepare() async {
    return await _populateTextsMap() && await generateNormalPlan();
  }

  Future<void> start(DifficultyType difficulty) async {
    await _fulfillNormalPlan(difficulty);
  }
}

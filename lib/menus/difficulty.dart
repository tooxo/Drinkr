import 'dart:ui';
import 'package:Drinkr/games/game_controller.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/widgets/custom_difficulty.dart';
import 'package:Drinkr/widgets/gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DifficultyType {
  static DifficultyType EASY = DifficultyType(
      startShots: 0, endShots: 0, startSips: 0, endSips: 0, name: "EASY");
  static DifficultyType MEDIUM = DifficultyType(
      startShots: 0, endShots: 0, startSips: 0, endSips: 0, name: "MEDIUM");
  static DifficultyType HARD = DifficultyType(
      startShots: 0, endShots: 0, startSips: 0, endSips: 0, name: "HARD");

  final int startShots;
  final int endShots;
  final int startSips;
  final int endSips;

  final int shotProbability;

  final String name;

  DifficultyType({
    required this.startShots,
    required this.endShots,
    required this.startSips,
    required this.endSips,
    required this.name,
    this.shotProbability = 50,
  });
}

class Difficulty extends StatefulWidget {
  static const int EASY = 0;
  static const int MIDDLE = 1;
  static const int HARD = 2;

  final List<Player> players;
  final int rounds;

  final List<GameType> enabledGames;

  const Difficulty(this.players, this.rounds, this.enabledGames);

  static const IconData mediumIcon =
      IconData(0xe800, fontFamily: "DifficultyIcons", fontPackage: null);
  static const IconData hardIcon =
      IconData(0xe801, fontFamily: "DifficultyIcons", fontPackage: null);
  static const IconData easyIcon =
      IconData(0xe802, fontFamily: "DifficultyIcons", fontPackage: null);

  @override
  State<StatefulWidget> createState() => DifficultyState();
}

class DifficultyState extends State<Difficulty> {
  late GameController controller;
  int displayState =
      1; // 1 Difficulty Selection, 2 Loading indicator, 3 Just Orange

  @override
  void initState() {
    super.initState();
    controller = GameController(
        widget.rounds, widget.enabledGames, widget.players, context);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  final AdRequest targetingInfo = AdRequest(
    keywords: ["trinken", "drinking", "alkohol", "alcohol"],
    nonPersonalizedAds: false,
    testDevices: [],
  );

  BannerAd? bannerAd;

  @override
  void dispose() {
    if (bannerAd != null) {
      bannerAd!.dispose().then((value) => bannerAd = null);
    }
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    super.dispose();
  }

  selectDifficulty(DifficultyType selectedDifficulty) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    this.displayState = 3;
    setState(() {});
    controller.start(selectedDifficulty);
  }

  int linearProgress = 1;
  int linearMax = 2;

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
            body: Container(
              constraints: BoxConstraints.expand(),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 140,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: TwoColorGradient(
                        color1: Color.fromRGBO(255, 168, 0, 1),
                        color2: Color.fromRGBO(255, 92, 0, 1),
                        roundness: 30,
                        child: Center(
                          child: ListTile(
                            onTap: () => selectDifficulty(DifficultyType.EASY),
                            leading: Icon(
                              Difficulty.easyIcon,
                              size: 60,
                              color: Colors.white,
                            ),
                            title: Text(
                              "Leicht",
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.w800,
                              ),
                            ).tr(),
                            subtitle: Text(
                              "1-2 Schlücke | 5 shots",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ).tr(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 140,
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
                      child: TwoColorGradient(
                        color1: Color.fromRGBO(255, 92, 0, 1),
                        color2: Color.fromRGBO(255, 0, 0, 1),
                        roundness: 30,
                        child: Center(
                          child: ListTile(
                            onTap: () => selectDifficulty(DifficultyType.EASY),
                            leading: Icon(
                              Difficulty.mediumIcon,
                              size: 60,
                              color: Colors.white,
                            ),
                            title: Text(
                              "Normal",
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.w800,
                              ),
                            ).tr(),
                            subtitle: Text(
                              "1-2 Schlücke | 5 shots",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ).tr(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 140,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: TwoColorGradient(
                        color1: Color.fromRGBO(255, 0, 0, 1),
                        color2: Color.fromRGBO(118, 0, 0, 1),
                        roundness: 30,
                        child: Center(
                          child: ListTile(
                            onTap: () => selectDifficulty(DifficultyType.HARD),
                            leading: Icon(
                              Difficulty.hardIcon,
                              size: 60,
                              color: Colors.white,
                            ),
                            title: Text(
                              "Absturz",
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.w800,
                              ),
                            ).tr(),
                            subtitle: Text(
                              "1-2 Schlücke | 5 shots",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ).tr(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                DifficultyType? difficulty = await showDialog(
                  context: context,
                  builder: (BuildContext context) => CustomDifficulty(),
                );
              },
              child: Icon(
                Icons.add,
                size: 25,
              ),
            ),
          )
        : this.displayState == 2
            ? Container(
                height: 20,
                color: Color.fromRGBO(21, 21, 21, 1),
                child: LinearProgressIndicator(
                  value: linearProgress / linearMax,
                  backgroundColor: Color.fromRGBO(21, 21, 21, 1),
                  valueColor: const AlwaysStoppedAnimation(Colors.deepOrange),
                ),
              )
            : Container(
                color: Colors.black,
              );
  }
}

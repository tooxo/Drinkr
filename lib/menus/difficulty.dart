import 'dart:ui';
import 'package:Drinkr/games/game_controller.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

class DifficultyState extends State<Difficulty> {
  GameController controller;
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

  selectDifficulty(int selectedDifficulty) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    this.displayState = 2;
    setState(() {});
    controller.start(selectedDifficulty);
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
                        activeColor: Colors.deepOrange,
                        onChanged: (bool value) {},
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

import 'dart:convert';

import 'package:SaufApp/game.dart';
import 'package:SaufApp/text_widget.dart';
import 'package:SaufApp/types.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'player.dart';

class TruthOrDare extends BasicGame {
  final String title = "truthOrDare";

  final Color primaryColor = Color.fromRGBO(255, 23, 68, 1);
  final Color secondaryColor = Color.fromRGBO(255, 89, 104, 1);

  final GameType type = GameType.TRUTH;

  final int drinkingDisplay = 1;

  TruthOrDare(List<Player> players, int difficulty, String text)
      : super(players, difficulty, text);

  @override
  String get mainTitle => text;

  @override
  State<StatefulWidget> createState() => new TruthOrDareState();
}

class TruthOrDareState extends BasicGameState {
  bool truth = false;
  bool showSolution = false;

  @override
  Widget buildWithoutSolution() {
    return !showSolution
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextWidget(widget.selectedPlayer[0].name),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 32, right: 32, top: 10),
                          child: SizedBox.expand(
                            child: ShowUpAnimation(
                              offset: 0,
                              child: MaterialButton(
                                color: widget.secondaryColor,
                                onPressed: () {
                                  showSolution = true;
                                  truth = true;
                                  setState(() {});
                                },
                                child: FittedBox(
                                  child: Text(
                                    "Wahrheit",
                                    style: GoogleFonts.caveatBrush(
                                      textStyle: TextStyle(color: Colors.black),
                                      fontSize: 450,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 32, right: 32, top: 10),
                          child: SizedBox.expand(
                            child: ShowUpAnimation(
                              offset: 0,
                              child: MaterialButton(
                                color: widget.secondaryColor,
                                onPressed: () {
                                  showSolution = true;
                                  truth = false;
                                  setState(() {});
                                },
                                child: FittedBox(
                                  child: Text(
                                    "Pflicht",
                                    style: GoogleFonts.caveatBrush(
                                      textStyle: TextStyle(color: Colors.black),
                                      fontSize: 450,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : TextWidget(this.truth
            ? "truth".tr() + ": " + jsonDecode(widget.mainTitle)["truth"]
            : "dare".tr() + ": " + jsonDecode(widget.mainTitle)["dare"]);
  }
}

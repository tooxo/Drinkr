import 'dart:convert';

import 'package:drinkr/games/game.dart';
import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/widgets/text_widget.dart';
import 'package:drinkr/utils/types.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/player.dart';

class TruthOrDare extends BasicGame {
  @override
  final String title = "truthOrDare";

  @override
  final Color backgroundColor1 = Color.fromRGBO(112, 13, 129, 1);
  @override
  final Color backgroundColor2 = Color.fromRGBO(222, 15, 15, 1);

  @override
  final GameType type = GameType.truth;

  @override
  final int drinkingDisplay = 1;

  TruthOrDare(Player player, DifficultyType difficulty, String text)
      : super(player, difficulty, text);

  @override
  String get mainTitle => text;

  @override
  State<StatefulWidget> createState() => TruthOrDareState();
}

class TruthOrDareState extends BasicGameState {
  bool truth = false;
  @override
  bool showSolution = false;

  @override
  String buildTitle() {
    if (!showSolution) {
      return widget.title;
    }
    if (truth) {
      return "truth";
    } else {
      return "dare";
    }
  }

  @override
  Widget buildWithoutSolution() {
    return showSolution
        ? Padding(
            padding: const EdgeInsets.only(
              left: 32,
              right: 32,
              top: 10,
            ),
            child: TextWidget(
              "${widget.selectedPlayer.name} – ${truth ? jsonDecode(widget.mainTitle)["truth"] : jsonDecode(widget.mainTitle)["dare"]}",
              textColor: widget.textColor,
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ShowUpAnimation(
                        offset: 0,
                        child: Text(
                          widget.selectedPlayer.name,
                          style: GoogleFonts.nunito(
                            color: widget.textColor,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 32,
                                right: 32,
                                top: 10,
                              ),
                              child: ShowUpAnimation(
                                offset: 0,
                                child: MaterialButton(
                                  elevation: 0,
                                  height: 120,
                                  color: widget.buttonColor,
                                  onPressed: () {
                                    showSolution = true;
                                    truth = true;
                                    setState(() {});
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  child: FittedBox(
                                    child: Text(
                                      "truth",
                                      style: GoogleFonts.nunito(
                                        textStyle:
                                            TextStyle(color: widget.textColor),
                                        fontSize: 45,
                                      ),
                                    ).tr(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 32, right: 32, top: 10),
                              child: ShowUpAnimation(
                                offset: 0,
                                child: MaterialButton(
                                  elevation: 0,
                                  height: 120,
                                  color: widget.buttonColor,
                                  onPressed: () {
                                    showSolution = true;
                                    truth = false;
                                    setState(() {});
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                  child: FittedBox(
                                    child: Text(
                                      "dare",
                                      style: GoogleFonts.nunito(
                                        textStyle:
                                            TextStyle(color: widget.textColor),
                                        fontSize: 45,
                                      ),
                                    ).tr(),
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
              ),
            ],
          );
  }
}

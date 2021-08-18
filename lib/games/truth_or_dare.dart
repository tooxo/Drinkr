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
  final String title = "truthOrDare";

  final Color backgroundColor1 = Color.fromRGBO(112, 13, 129, 1);
  final Color backgroundColor2 = Color.fromRGBO(222, 15, 15, 1);

  final GameType type = GameType.TRUTH;

  final int drinkingDisplay = 1;

  TruthOrDare(Player player, DifficultyType difficulty, String text)
      : super(player, difficulty, text);

  @override
  String get mainTitle => text;

  @override
  State<StatefulWidget> createState() => TruthOrDareState();
}

const _kFontFam = 'Icons';
const _kFontPkg = null;
const IconData dice =
    IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);

class TruthOrDareState extends BasicGameState {
  bool truth = false;
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
    return Column(
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
                        color: widget.textColor, fontSize: 30),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(),
                child: this.showSolution
                    ? TextWidget(
                        this.truth
                            ? jsonDecode(widget.mainTitle)["truth"]
                            : jsonDecode(widget.mainTitle)["dare"],
                        textColor: widget.textColor,
                      )
                    : Row(
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

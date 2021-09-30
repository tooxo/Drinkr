import 'package:drinkr/games/game.dart';
import 'package:drinkr/utils/types.dart';
import 'package:flutter/material.dart';

class Guessing extends BasicGame {
  @override
  final Color backgroundColor1 = Color.fromRGBO(64, 13, 129, 1);
  @override
  final Color backgroundColor2 = Color.fromRGBO(105, 13, 222, 1);

  @override
  final String title = "guessing";

  @override
  final bool showSolutionButton = true;
  @override
  final int drinkingDisplay = 1;

  @override
  final GameType type = GameType.guess;

  Guessing(players, difficulty, text) : super(players, difficulty, text);

  @override
  String get mainTitle => text.split(";")[0];

  @override
  String get solutionText => text.split(";")[1];
}

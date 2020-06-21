import 'package:SaufApp/game.dart';
import 'package:SaufApp/types.dart';
import 'package:flutter/material.dart';

class Guessing extends BasicGame {
  final Color primaryColor = Color.fromRGBO(156, 39, 176, 1);
  final Color secondaryColor = Color.fromRGBO(208, 92, 227, 1);

  final String title = "guessing";

  final bool showSolutionButton = true;
  final int drinkingDisplay = 1;

  final GameType type = GameType.GUESS;

  Guessing(players, difficulty, text) : super(players, difficulty, text);

  @override
  String get mainTitle => text.split(";")[0];

  @override
  String get solutionText => text.split(";")[1];
}

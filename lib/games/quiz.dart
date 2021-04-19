import 'package:Drinkr/games/game.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:flutter/material.dart';

class Quiz extends BasicGame {
  final Color backgroundColor1 = Color.fromRGBO(13, 66, 129, 1);
  final Color backgroundColor2 = Color.fromRGBO(13, 108, 129, 1);

  final bool showSolutionButton = true;

  final GameType type = GameType.QUIZ;

  final String title = "bigBrainQuiz";

  Quiz(List<Player> players, int difficulty, String text)
      : super(players, difficulty, text);

  @override
  String get mainTitle =>
      selectedPlayer[0].name + " – " + this.text.split(";")[0];

  @override
  String get solutionText => this.text.split(";")[1];
}

import 'package:drinkr/games/game.dart';
import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/utils/player.dart';
import 'package:drinkr/utils/types.dart';
import 'package:flutter/material.dart';

class Quiz extends BasicGame {
  final Color backgroundColor1 = Color.fromRGBO(13, 66, 129, 1);
  final Color backgroundColor2 = Color.fromRGBO(13, 108, 129, 1);

  final bool showSolutionButton = true;

  final GameType type = GameType.QUIZ;

  final String title = "bigBrainQuiz";

  Quiz(Player player, DifficultyType difficulty, String text)
      : super(player, difficulty, text);

  @override
  String get mainTitle =>
      selectedPlayer.name + " – " + this.text.split(";")[0];

  @override
  String get solutionText => this.text.split(";")[1];
}

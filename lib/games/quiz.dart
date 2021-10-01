import 'package:drinkr/games/game.dart';
import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/utils/player.dart';
import 'package:drinkr/utils/types.dart';
import 'package:flutter/material.dart';

class Quiz extends BasicGame {
  @override
  final Color backgroundColor1 = Color.fromRGBO(13, 66, 129, 1);
  @override
  final Color backgroundColor2 = Color.fromRGBO(13, 108, 129, 1);

  @override
  final bool showSolutionButton = true;

  @override
  final GameType type = GameType.quiz;

  @override
  final String title = "bigBrainQuiz";

  Quiz(Player player, DifficultyType difficulty, String text)
      : super(player, difficulty, text);

  @override
  String get mainTitle =>
      selectedPlayer.name + " – " + text.split(";")[0];

  @override
  String get solutionText => text.split(";")[1];
}

import 'package:SaufApp/game.dart';
import 'package:SaufApp/player.dart';
import 'package:SaufApp/types.dart';
import 'package:flutter/material.dart';
import 'file.dart';

class Quiz extends BasicGame {
  final Color primaryColor = Color.fromRGBO(2, 119, 189, 1);
  final Color secondaryColor = Color.fromRGBO(88, 165, 240, 1);

  final bool showSolutionButton = true;

  final GameType type = GameType.QUIZ;

  final String title = "bigBrainQuiz";

  Quiz(List<Player> players, int difficulty, String text)
      : super(players, difficulty, text);

  @override
  String get mainTitle =>
      selectedPlayer[0].name + ": " + this.text.split(";")[0];

  @override
  String get solutionText => this.text.split(";")[1];
}

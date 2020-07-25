import 'package:BoozeBuddy/games/game.dart';
import 'package:BoozeBuddy/utils/types.dart';
import 'package:flutter/material.dart';

class Opinion extends BasicGame {
  final String title = "wouldYouRather";

  final Color primaryColor = Color.fromRGBO(253, 216, 53, 1);
  final Color secondaryColor = Color.fromRGBO(255, 255, 107, 1);

  final int drinkingDisplay = 1;

  final GameType type = GameType.OPINION;

  Opinion(players, difficulty, text) : super(players, difficulty, text);

  @override
  String get mainTitle => text;
}

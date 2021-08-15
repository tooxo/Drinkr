import 'package:drinkr/games/game.dart';
import 'package:drinkr/utils/types.dart';
import 'package:flutter/material.dart';

class Opinion extends BasicGame {
  final String title = "wouldYouRather";

  final Color backgroundColor1 = Color.fromRGBO(254, 140, 0, 1);
  final Color backgroundColor2 = Color.fromRGBO(248, 54, 0, 1);

  final int drinkingDisplay = 1;

  final GameType type = GameType.OPINION;

  Opinion(players, difficulty, text) : super(players, difficulty, text);

  @override
  String get mainTitle => text;
}

import 'package:drinkr/games/game.dart';
import 'package:drinkr/utils/types.dart';
import 'package:flutter/material.dart';

class Opinion extends BasicGame {
  @override
  final String title = "wouldYouRather";

  @override
  final Color backgroundColor1 = Color.fromRGBO(254, 140, 0, 1);
  @override
  final Color backgroundColor2 = Color.fromRGBO(248, 54, 0, 1);

  @override
  final int drinkingDisplay = 1;

  @override
  final GameType type = GameType.opinion;

  Opinion(players, difficulty, text) : super(players, difficulty, text);

  @override
  String get mainTitle => text;
}

import 'package:Drinkr/games/game.dart';
import 'package:Drinkr/menus/difficulty.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:flutter/material.dart';
import '../utils/player.dart';

class WhoWouldRather extends BasicGame {
  final String title = "whoWouldRather";
  final GameType type = GameType.WHO_WOULD_RATHER;

  final Color backgroundColor1 = Color.fromRGBO(57, 13, 129, 1);
  final Color backgroundColor2 = Color.fromRGBO(129, 18, 124, 1);

  final int drinkingDisplay = 1;

  WhoWouldRather(Player player, DifficultyType difficulty, String text)
      : super(player, difficulty, text);

  @override
  String get mainTitle => text;
}

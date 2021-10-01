import 'package:drinkr/games/game.dart';
import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/utils/types.dart';
import 'package:flutter/material.dart';
import '../utils/player.dart';

class WhoWouldRather extends BasicGame {
  @override
  final String title = "whoWouldRather";
  @override
  final GameType type = GameType.whoWouldRather;

  @override
  final Color backgroundColor1 = Color.fromRGBO(57, 13, 129, 1);
  @override
  final Color backgroundColor2 = Color.fromRGBO(129, 18, 124, 1);

  @override
  final int drinkingDisplay = 1;

  WhoWouldRather(Player player, DifficultyType difficulty, String text)
      : super(player, difficulty, text);

  @override
  String get mainTitle => text;
}

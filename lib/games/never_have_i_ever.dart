import 'package:drinkr/games/game.dart';
import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/utils/types.dart';
import 'package:flutter/material.dart';
import '../utils/player.dart';

class NeverHaveIEver extends BasicGame {
  @override
  final String title = "neverHaveIEver";
  @override
  final GameType type = GameType.neverHaveIEver;

  @override
  final Color backgroundColor1 = Color.fromRGBO(222, 0, 0, 1);
  @override
  final Color backgroundColor2 = Color.fromRGBO(255, 12, 186, 1);

  @override
  final int drinkingDisplay = 1;

  NeverHaveIEver(Player player, DifficultyType difficulty, String text)
      : super(player, difficulty, text);

  @override
  String get mainTitle => text;
}

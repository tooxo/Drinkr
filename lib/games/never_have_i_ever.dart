import 'package:Drinkr/games/game.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:flutter/material.dart';
import '../utils/player.dart';

class NeverHaveIEver extends BasicGame {
  final String title = "neverHaveIEver";
  final GameType type = GameType.NEVER_HAVE_I_EVER;

  final Color backgroundColor1 = Color.fromRGBO(222, 0, 0, 1);
  final Color backgroundColor2 = Color.fromRGBO(255, 12, 186, 1);

  final int drinkingDisplay = 1;

  NeverHaveIEver(Player player, int difficulty, String text)
      : super(player, difficulty, text);

  @override
  String get mainTitle => text;
}

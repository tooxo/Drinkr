import 'package:SaufApp/game.dart';
import 'package:SaufApp/types.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'file.dart';

class NeverHaveIEver extends BasicGame {
  final String title = "neverHaveIEver";
  final GameType type = GameType.NEVER_HAVE_I_EVER;
  final Color primaryColor = Color.fromRGBO(211, 47, 47, 1);
  final Color secondaryColor = Color.fromRGBO(255, 102, 89, 1);

  final int drinkingDisplay = 1;

  NeverHaveIEver(List<Player> players, int difficulty, String text)
      : super(players, difficulty, text);

  @override
  String get mainTitle => text;
}

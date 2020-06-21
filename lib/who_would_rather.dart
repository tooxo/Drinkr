import 'package:SaufApp/game.dart';
import 'package:SaufApp/types.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'file.dart';

class WhoWouldRather extends BasicGame {
  final String title = "whoWouldRather";
  final GameType type = GameType.WHO_WOULD_RATHER;
  final Color primaryColor = Color.fromRGBO(255, 0, 98, 1);
  final Color secondaryColor = Color.fromRGBO(255, 92, 143, 1);

  final int drinkingDisplay = 1;

  WhoWouldRather(List<Player> players, int difficulty, String text)
      : super(players, difficulty, text);

  @override
  String get mainTitle => text;
}

import 'dart:math';

import 'package:BoozeBuddy/games/game.dart';
import 'package:BoozeBuddy/utils/player.dart';
import 'package:flutter/material.dart';

import '../utils/drinking.dart';

class Challenges extends BasicGame {
  final Color primaryColor = Color.fromRGBO(0, 150, 136, 1);
  final Color secondaryColor = Color.fromRGBO(82, 199, 184, 1);

  final int drinkingDisplay = 0;

  Challenges(List<Player> players, int difficulty, String text)
      : super(players, difficulty, text);

  final String title = "challenges";

  @override
  String get mainTitle {
    String raw = text.replaceAll(
        "%player", players[Random.secure().nextInt(players.length)].name);
    int amountShots = Drinking.getDrinkAmountShot(difficulty);
    if (amountShots > 1) {
      raw = raw.replaceAll("%amountshot", "$amountShots Shots");
    } else if (amountShots == 0) {
      raw = raw.replaceAll("%amountshot", "%amountbeer");
    } else {
      raw = raw.replaceAll("%amountshot", "$amountShots Shot");
    }
    int amountBeer = Drinking.getDrinkAmountBeer(difficulty);
    if (amountBeer > 1) {
      raw = raw.replaceAll("%amountbeer", "$amountBeer Schlucke");
    } else {
      raw = raw.replaceAll("%amountbeer", "$amountBeer Schluck");
    }
    return raw;
  }
}

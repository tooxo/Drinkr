import 'dart:math';

import 'package:Drinkr/games/game.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/drinking.dart';

class Challenges extends BasicGame {
  final Color backgroundColor1 = Color.fromRGBO(45, 48, 120, 1);
  final Color backgroundColor2 = Color.fromRGBO(110, 65, 239, 1);
  final Color buttonColor = Color.fromRGBO(29, 29, 69, .3);
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
      raw = raw.replaceAll("%amountbeer", "$amountBeer " + "sips".tr());
    } else {
      raw = raw.replaceAll("%amountbeer", "$amountBeer " + "sip".tr());
    }
    return raw;
  }
}

import 'dart:ui';
import 'package:Drinkr/games/game_controller.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/widgets/custom_difficulty.dart';
import 'package:Drinkr/widgets/gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DifficultyType {
  static DifficultyType EASY = DifficultyType(
      startShots: 0, endShots: 0, startSips: 1, endSips: 2, name: "EASY");
  static DifficultyType MEDIUM = DifficultyType(
      startShots: 1, endShots: 2, startSips: 2, endSips: 3, name: "MEDIUM");
  static DifficultyType HARD = DifficultyType(
      startShots: 2, endShots: 3, startSips: 4, endSips: 5, name: "HARD");

  final int startShots;
  final int endShots;
  final int startSips;
  final int endSips;

  final int shotProbability;

  final String name;

  DifficultyType({
    required this.startShots,
    required this.endShots,
    required this.startSips,
    required this.endSips,
    required this.name,
    this.shotProbability = 50,
  });
}

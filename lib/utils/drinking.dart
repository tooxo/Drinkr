import 'dart:math';
import 'dart:ui';

import 'package:Drinkr/utils/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Drinking {
  /// Returns a random amount of sips according to the given [difficulty]
  static int getDrinkAmountBeer(DifficultyType difficulty) {
    return Random.secure()
            .nextInt(difficulty.endSips - difficulty.startSips + 1) +
        difficulty.startSips;
  }

  /// Returns a random amount of shots according to the given [difficulty]
  static int getDrinkAmountShot(DifficultyType difficulty) {
    return Random.secure()
            .nextInt(difficulty.endShots - difficulty.endShots + 1) +
        difficulty.startShots;
  }

  /// Returns if the action is a shot or a beer according to the [difficulty]
  static bool isShot(DifficultyType difficulty) {
    return difficulty.shotProbability < Random.secure().nextInt(101);
  }

  static List generateRandomAmount(DifficultyType difficulty) {
    bool _isShot = Drinking.isShot(difficulty);
    return [
      _isShot,
      _isShot ? getDrinkAmountShot(difficulty) : getDrinkAmountBeer(difficulty)
    ];
  }
}

class DrinkingDisplay extends StatelessWidget {
  final bool isShot;
  final int amount;
  final Color tintColor;

  static const IconData beer_outline =
      IconData(0xe800, fontFamily: 'Icons', fontPackage: null);
  static const IconData shot_glass =
      IconData(0xe801, fontFamily: 'Icons', fontPackage: null);

  const DrinkingDisplay(this.isShot, this.amount, this.tintColor);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          amount.toString() + " × ", // Unicode Multiply Sign
          style: GoogleFonts.nunito(
            fontSize: 30,
            color: tintColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 8, 8.0),
          child: FittedBox(
            child: Icon(
              isShot ? shot_glass : beer_outline,
              size: 5000,
              color: tintColor,
            ),
          ),
        )
      ],
    );
  }
}

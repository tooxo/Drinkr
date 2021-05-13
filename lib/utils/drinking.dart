import 'dart:math';
import 'dart:ui';

import 'package:Drinkr/menus/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Drinking {
  int amount = 0;
  bool shot = false;

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

class DrinkingDisplay extends StatefulWidget {
  final bool isShot;
  final int amount;
  final Color tintColor;

  static const IconData beer_outline =
      IconData(0xe800, fontFamily: 'Icons', fontPackage: null);
  static const IconData shot_glass =
      IconData(0xe801, fontFamily: 'Icons', fontPackage: null);

  const DrinkingDisplay(this.isShot, this.amount, this.tintColor);

  @override
  State<StatefulWidget> createState() => DrinkingDisplayState();
}

class DrinkingDisplayState extends State<DrinkingDisplay> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FittedBox(
                child: Text(
                  widget.amount.toString() + " × ", // Unicode Multiply Sign
                  style: GoogleFonts.nunito(
                    fontSize: 5000,
                    color: widget.tintColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8.0),
                child: FittedBox(
                  child: Icon(
                    widget.isShot
                        ? DrinkingDisplay.shot_glass
                        : DrinkingDisplay.beer_outline,
                    size: 5000,
                    color: widget.tintColor,
                  ),
                ),
              )
            ],
          )
        : Container();
  }
}

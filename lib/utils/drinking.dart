import 'dart:math';

import 'package:SaufApp/menus/difficulty.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Drinking {
  int amount = 0;
  bool shot = false;

  /// Formats a string to the given parameters
  static String formatString(int amount, bool isShot, bool chug) {
    if (isShot && amount > 1) {
      return "$amount shots";
    } else if (isShot && amount <= 1) {
      return "$amount shot";
    } else if (!isShot && amount > 1) {
      return "$amount Schlücke";
    } else if (!isShot && amount <= 1) {
      return "$amount Schluck";
    } else if (chug && !isShot) {
      return "Exe dein Getränk";
    } else {
      return "";
    }
  }

  /// Returns a random amount of sips according to the given [difficulty]
  static int getDrinkAmountBeer(int difficulty) {
    switch (difficulty) {
      case Difficulty.EASY:
        return Random.secure().nextInt(2) + 1; // Random 1-2
      case Difficulty.MIDDLE:
        return Random.secure().nextInt(2) + 2; // Random 2-3
      case Difficulty.HARD:
        return Random.secure().nextInt(3) + 3; // Random 3-5
      default:
        return 0;
    }
  }

  /// Returns a random amount of shots according to the given [difficulty]
  static int getDrinkAmountShot(int difficulty) {
    switch (difficulty) {
      case Difficulty.EASY:
        return 0;
      case Difficulty.MIDDLE:
        return 1; //1
      case Difficulty.HARD:
        return Random.secure().nextInt(2) + 1; //1-2
      default:
        return 0;
    }
  }

  /// Returns if the action is a shot or a beer according to the [difficulty]
  static bool isShot(int difficulty) {
    switch (difficulty) {
      case Difficulty.MIDDLE:
        return Random.secure().nextInt(5) + 1 == 3;
      case Difficulty.HARD:
        return Random.secure().nextInt(3) + 1 == 3;
    }
    return false;
  }


  static List generateRandomAmount(int difficulty) {
    bool _isShot = Drinking.isShot(difficulty);
    if (_isShot) {
      return [true, getDrinkAmountShot(difficulty)];
    } else {
      return [false, getDrinkAmountBeer(difficulty)];
    }
  }

  static String betterStringFunctionByTillFuckYouArte(List l) {
    bool isShot = l[0];
    int amount = l[1];
    String drinkString;
    if (isShot && amount == 1) {
      drinkString = "Shot";
    }
    if (isShot && amount != 1) {
      drinkString = "Shots";
    }
    if (!isShot && amount == 1) {
      drinkString = "Schluck";
    }
    if (!isShot && amount != 1) {
      drinkString = "Schlücke";
    }
    return "$amount $drinkString";
  }
}

class DrinkingDisplay extends StatelessWidget {
  final bool isShot;
  final int amount;
  final Color tintColor;

  static const _kFontFam = 'Main';
  static const _kFontPkg = null;

  static const IconData beer_outline =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData shot_glass =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  const DrinkingDisplay(this.isShot, this.amount, this.tintColor);

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FittedBox(
          child: Text(
            amount.toString() + "×",
            style:
                GoogleFonts.caveatBrush(fontSize: 5000, color: this.tintColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 8, 8.0),
          child: FittedBox(
            child: Icon(
              this.isShot ? shot_glass : beer_outline,
              size: 5000,
              color: this.tintColor,
            ),
          ),
        )
      ],
    ): Container();
  }
}
import 'dart:ui';

import 'package:Drinkr/menus/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomDifficulty extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CustomDifficultyState();
}

class CustomDifficultyState extends State<CustomDifficulty> {
  final int maxValue = 9;
  final Color enabledColor = Colors.white;
  final Color disabledColor = Colors.grey.shade800;

  String name = "";

  bool sipsEnabled = true;
  bool shotsEnabled = true;

  int startSip = 0;
  int endSip = 0;

  int startShot = 0;
  int endShot = 0;

  DifficultyType generateDifficultyType() {
    int shotsA = 0;
    int shotsB = 0;

    int sipsA = 0;
    int sipsB = 0;

    if (sipsEnabled) {
      sipsA = this.startSip;
      sipsB = this.endSip;
    }

    if (shotsEnabled) {
      shotsA = this.startShot;
      shotsB = this.endShot;
    }

    return DifficultyType(
      startShots: shotsA,
      endShots: shotsB,
      startSips: sipsA,
      endSips: sipsB,
      name: this.name,
    );
  }

  bool illegal() {
    if (this.name.isEmpty) {
      return true;
    }
    if (this.sipsEnabled) {
      if (this.startSip > this.endSip) {
        return true;
      }
    }
    if (this.shotsEnabled) {
      if (this.startShot > this.endShot) {
        return true;
      }
    }
    return false;
  }

  void switchSipsEnabled(bool? _) {
    setState(() {
      if (!shotsEnabled && sipsEnabled) {
        shotsEnabled = !shotsEnabled;
      }
      sipsEnabled = !sipsEnabled;
    });
  }

  void switchShotsEnabled(bool? _) {
    setState(() {
      if (!sipsEnabled && shotsEnabled) {
        sipsEnabled = !sipsEnabled;
      }
      shotsEnabled = !shotsEnabled;
    });
  }

  void incrementStartSips() {
    if (startSip == maxValue) {
      return;
    }
    setState(() {
      startSip++;
    });
  }

  void decrementStartSips() {
    if (startSip == 0) {
      return;
    }
    setState(() {
      startSip--;
    });
  }

  void incrementEndSips() {
    if (endSip == maxValue) {
      return;
    }
    setState(() {
      endSip++;
    });
  }

  void decrementEndSips() {
    if (endSip == 0) {
      return;
    }
    setState(() {
      endSip--;
    });
  }

  void incrementStartShots() {
    if (startShot == maxValue) {
      return;
    }
    setState(() {
      startShot++;
    });
  }

  void decrementStartShots() {
    if (startShot == 0) {
      return;
    }
    setState(() {
      startShot--;
    });
  }

  void incrementEndShots() {
    if (endShot == maxValue) {
      return;
    }
    setState(() {
      endShot++;
    });
  }

  void decrementEndShots() {
    if (endShot == 0) {
      return;
    }
    setState(() {
      endShot--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: AlertDialog(
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: TextField(
          style: GoogleFonts.nunito(
            fontSize: 20,
            color: Colors.white,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: "Name der Schwierigkeit...".tr(),
            hintStyle: GoogleFonts.nunito(
              fontSize: 20,
              color: Colors.white.withOpacity(0.5),
            ),
            border: InputBorder.none,
          ),
          onChanged: (String newValue) => setState(() => this.name = newValue),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 2,
                  child: Checkbox(
                    value: sipsEnabled,
                    focusColor: Colors.white,
                    checkColor: Colors.white,
                    activeColor: Colors.deepOrange,
                    onChanged: switchSipsEnabled,
                  ),
                ),
                Text(
                  "Schlück(e)",
                  style: GoogleFonts.nunito(
                    fontSize: 25,
                    color: this.sipsEnabled
                        ? this.enabledColor
                        : this.disabledColor,
                  ),
                ).tr(),
                Row(
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline,
                            size: 30,
                            color: this.sipsEnabled
                                ? this.enabledColor
                                : this.disabledColor,
                          ),
                          onPressed:
                              this.sipsEnabled ? incrementStartSips : null,
                        ),
                        Text(
                          "$startSip",
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(),
                            fontSize: 25,
                            color: this.sipsEnabled
                                ? this.enabledColor
                                : this.disabledColor,
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 30,
                              color: this.sipsEnabled
                                  ? this.enabledColor
                                  : this.disabledColor,
                            ),
                            onPressed:
                                this.sipsEnabled ? decrementStartSips : null),
                      ],
                    ),
                    Icon(
                      Icons.remove,
                      color: this.sipsEnabled
                          ? this.startSip > this.endSip
                              ? Colors.red
                              : this.enabledColor
                          : this.disabledColor,
                    ),
                    Column(
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 30,
                              color: this.sipsEnabled
                                  ? this.enabledColor
                                  : this.disabledColor,
                            ),
                            onPressed:
                                this.sipsEnabled ? incrementEndSips : null),
                        Text(
                          "$endSip",
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(),
                            fontSize: 25,
                            color: this.sipsEnabled
                                ? this.enabledColor
                                : this.disabledColor,
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 30,
                              color: this.sipsEnabled
                                  ? this.enabledColor
                                  : this.disabledColor,
                            ),
                            onPressed:
                                this.sipsEnabled ? decrementEndSips : null),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 2,
                  child: Checkbox(
                    value: shotsEnabled,
                    focusColor: Colors.white,
                    checkColor: Colors.white,
                    activeColor: Colors.deepOrange,
                    onChanged: switchShotsEnabled,
                  ),
                ),
                Text(
                  "Shot(s)",
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(),
                    fontSize: 25,
                    color: this.shotsEnabled
                        ? this.enabledColor
                        : this.disabledColor,
                  ),
                ).tr(),
                Row(
                  children: [
                    Column(
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 30,
                              color: this.shotsEnabled
                                  ? this.enabledColor
                                  : this.disabledColor,
                            ),
                            onPressed:
                                this.shotsEnabled ? incrementStartShots : null),
                        Text(
                          "$startShot",
                          style: GoogleFonts.nunito(
                            fontSize: 25,
                            color: this.shotsEnabled
                                ? this.enabledColor
                                : this.disabledColor,
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 30,
                              color: this.shotsEnabled
                                  ? this.enabledColor
                                  : this.disabledColor,
                            ),
                            onPressed:
                                this.shotsEnabled ? decrementStartShots : null),
                      ],
                    ),
                    Icon(
                      Icons.remove,
                      color: this.shotsEnabled
                          ? this.startShot > this.endShot
                              ? Colors.red
                              : this.enabledColor
                          : this.disabledColor,
                    ),
                    Column(
                      children: [
                        IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 30,
                              color: this.shotsEnabled
                                  ? this.enabledColor
                                  : this.disabledColor,
                            ),
                            onPressed:
                                this.shotsEnabled ? incrementEndShots : null),
                        Text(
                          "$endShot",
                          style: GoogleFonts.nunito(
                            textStyle: TextStyle(),
                            fontSize: 25,
                            color: this.shotsEnabled
                                ? this.enabledColor
                                : this.disabledColor,
                          ),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: 30,
                              color: this.shotsEnabled
                                  ? this.enabledColor
                                  : this.disabledColor,
                            ),
                            onPressed:
                                this.shotsEnabled ? decrementEndShots : null),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 50),
            child: GestureDetector(
              onTap: this.illegal()
                  ? null
                  : () => Navigator.pop(context, generateDifficultyType()),
              child: Container(
                color: Color.fromRGBO(21, 21, 21, 1),
                child: Container(
                  height: 50,
                  width: 350.0,
                  decoration: BoxDecoration(
                    color: this.illegal()
                        ? Colors.grey.shade700
                        : Colors.deepOrange,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.8),
                        blurRadius: 8,
                        offset: Offset(2, 10),
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Schwierigkeit auswählen",
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800),
                        ).tr(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

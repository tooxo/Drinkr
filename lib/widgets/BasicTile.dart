import 'dart:ui';

import 'package:Drinkr/menus/difficulty.dart';
import 'package:Drinkr/menus/name_select.dart';
import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/widgets/gradient.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart';

class BasicTile extends StatelessWidget {
  final double height;
  final Color mainColor;
  final Color secondaryColor;
  final IconData icon;
  final String title;
  final String description;
  final Color textColor;
  final IconData topIcon;
  final String games;
  final List<GameType> enabledGames;

  const BasicTile(
      {Key key,
      this.height = 120,
      this.mainColor,
      this.secondaryColor,
      this.icon,
      this.title,
      this.description,
      this.games,
      this.enabledGames,
      this.topIcon = Icons.info_outline,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Difficulty([Player("1234"), Player("1212334")], 100, enabledGames)));
          },
          child: Container(
            color: Color.fromRGBO(21, 21, 21, 1),
            child: Container(
              height: height,
              width: 350.0,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 8,
                  offset: Offset(2, 10), // changes position of shadow
                ),
              ], borderRadius: BorderRadius.all(Radius.circular(30))),
              child: TwoColorGradient(
                color1: mainColor,
                color2: secondaryColor,
                roundness: 30,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10, left: 10),
                      child: Icon(
                        icon,
                        size: 80,
                        color: textColor,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.nunito(
                              color: textColor,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ).tr(),
                          Text(
                            description,
                            style: GoogleFonts.nunito(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ).tr(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: IconButton(
                        icon: Icon(
                          topIcon,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          displayExitDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void displayExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              "Games",
              style: GoogleFonts.nunito(
                textStyle: TextStyle(),
                fontWeight: FontWeight.w800,
                fontSize: 30,
                color: Colors.white,
              ),
            ).tr(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Text(
              games,
              style: GoogleFonts.nunito(
                textStyle: TextStyle(),
                fontSize: 25,
                color: Colors.white,
              ),
            ).tr(),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                child: Text("Ok".tr(),
                    style:
                        GoogleFonts.nunito(color: Colors.white, fontSize: 20)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:math';

import 'package:Drinkr/utils/ad.dart';
import 'package:Drinkr/utils/file.dart';
import 'package:Drinkr/menus/licenses.dart';
import 'package:Drinkr/utils/shapes.dart';
import 'package:Drinkr/widgets/toggle_switch.dart';
import 'package:Drinkr/menus/word_customization.dart';
import 'package:app_review/app_review.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsState();
}

// TODO FIXME Add all items to translation

class SettingsState extends State<Settings> {
  static const String SETTING_INCLUSION_OF_QUESTIONS =
      "SETTING_INCLUSION_OF_QUESTIONS";

  static const int ONLY_INCLUDED = 0;
  static const int BOTH = 1;
  static const int ONLY_CUSTOM = 2;

  SharedPreferences sp;

  int sliderState = 1;
  bool customQuestionsAvailable = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      sp = value;
      sliderState = sp.getInt(SETTING_INCLUSION_OF_QUESTIONS) ?? 1;
      key.currentState.setIndex(sliderState);
      key.currentState.setState(() {});
    });
    updateCustomQuestionsAvailable();
    super.initState();
  }

  void updateCustomQuestionsAvailable() async {
    customQuestionsAvailable = await getNumberOfTextsLocal() > 0;
    if (!customQuestionsAvailable && sliderState == ONLY_CUSTOM) {
      sliderState = BOTH;
      await sp.setInt(SETTING_INCLUSION_OF_QUESTIONS, BOTH);
    }
    key.currentState
      ..setIndex(sliderState)
      ..setState(() {});
  }

  final GlobalKey<ToggleSwitchState> key = GlobalKey<ToggleSwitchState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        title: Text(
          "settings",
          style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ).tr(),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Werbung ausschalten",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "App Bewerten",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sprache",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Fragen/Vorschläge",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Licenses()));
                  },
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Über uns / Lizensen",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
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
        ),
      ),
    );
  }
}

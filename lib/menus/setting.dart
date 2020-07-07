import 'dart:math';

import 'package:SaufApp/utils/ad.dart';
import 'package:SaufApp/utils/file.dart';
import 'package:SaufApp/menus/licenses.dart';
import 'package:SaufApp/utils/shapes.dart';
import 'package:SaufApp/widgets/toggle_switch.dart';
import 'package:SaufApp/menus/word_customization.dart';
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
  State<StatefulWidget> createState() => new SettingsState();
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
    key.currentState..setIndex(sliderState)..setState(() {});
  }

  final GlobalKey<ToggleSwitchState> key = GlobalKey<ToggleSwitchState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        double calcDegree =
            (atan((c.maxHeight * 0.5 * 0.1) / c.maxWidth) * 180) / pi;
        double distanceOffset = (c.maxWidth * sin((calcDegree * pi / 180))) /
            sin(((90 - calcDegree) * pi) / 180);
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(255, 111, 0, 1),
            title: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 50.0),
                child: Text(
                  "settings",
                  style: GoogleFonts.caveatBrush(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w600),
                  ),
                ).tr(),
              ),
            ),
            iconTheme: IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            child: ColumnSuper(
              innerDistance: distanceOffset * -1 + 3,
              children: <Widget>[
                CustomPaint(
                  painter:
                      TopPainter(calcDegree, Color.fromRGBO(255, 111, 0, 1)),
                  child: Container(
                    height: 175,
                    child: SizedBox.expand(
                      child: Container(
                        margin: EdgeInsets.only(bottom: distanceOffset),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0, right: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Aktivierte Fragen",
                                style: GoogleFonts.caveatBrush(fontSize: 30),
                              ),
                              SizedBox(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: ToggleSwitch(
                                  key: key,
                                  minWidth: 120,
                                  minHeight: null,
                                  initialLabelIndex: sliderState,
                                  activeBgColor: Colors.deepOrange,
                                  activeTextColor: Colors.black,
                                  inactiveBgColor: Colors.orangeAccent,
                                  inactiveTextColor: Colors.black,
                                  labels: [
                                    'Only Included',
                                    'Both',
                                    'Only Custom'
                                  ],
                                  onToggle: (index) async {
                                    if (index == 2 &&
                                        !customQuestionsAvailable) {
                                      return false;
                                    }
                                    sp.setInt(
                                        SETTING_INCLUSION_OF_QUESTIONS, index);
                                    return true;
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
                CustomPaint(
                  painter: MiddlePainter(calcDegree, Colors.deepOrange),
                  child: Container(
                    height: 175,
                    width: c.maxWidth,
                    decoration: ShapeDecoration(
                        shape: MiddleShapePainter(0, calcDegree)),
                    child: Material(
                      color: Colors.transparent,
                      shape: MiddleShapePainter(0, calcDegree),
                      child: InkWell(
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => WordCustomization()))
                            .then((value) =>
                                this.updateCustomQuestionsAvailable()),
                        customBorder: MiddleShapePainter(0, calcDegree),
                        child: Container(
                          margin: EdgeInsets.only(
                              top: distanceOffset, bottom: distanceOffset),
                          child: Transform.rotate(
                            //angle: calcDegree * pi / 180 * -1,
                            angle: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "Eigene Fragen hinzufügen",
                                    textAlign: TextAlign.center,
                                    style:
                                        GoogleFonts.caveatBrush(fontSize: 300),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter:
                      MiddlePainter(calcDegree, Color.fromRGBO(255, 111, 0, 1)),
                  child: Container(
                    height: 175,
                    width: c.maxWidth,
                    decoration: ShapeDecoration(
                        shape: MiddleShapePainter(0, calcDegree)),
                    child: Material(
                      color: Colors.transparent,
                      shape: MiddleShapePainter(0, calcDegree),
                      child: InkWell(
                        onTap: () => showInterstitialAd(context),
                        customBorder: MiddleShapePainter(0, calcDegree),
                        child: Container(
                          margin: EdgeInsets.only(
                              top: distanceOffset, bottom: distanceOffset),
                          child: Transform.rotate(
                            //angle: calcDegree * pi / 180 * -1,
                            angle: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "Werbung Deaktivieren",
                                    textAlign: TextAlign.center,
                                    style:
                                        GoogleFonts.caveatBrush(fontSize: 300),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter: MiddlePainter(calcDegree, Colors.deepOrange),
                  child: Container(
                    height: 175,
                    width: c.maxWidth,
                    decoration: ShapeDecoration(
                        shape: MiddleShapePainter(0, calcDegree)),
                    child: Material(
                      color: Colors.transparent,
                      shape: MiddleShapePainter(0, calcDegree),
                      child: InkWell(
                        onTap: () =>
                            FlutterToast.showToast(msg: "Coming soon..."),
                        customBorder: MiddleShapePainter(0, calcDegree),
                        child: Container(
                          margin: EdgeInsets.only(
                              top: distanceOffset, bottom: distanceOffset),
                          child: Transform.rotate(
                            //angle: calcDegree * pi / 180 * -1,
                            angle: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "Sprache Ändern",
                                    textAlign: TextAlign.center,
                                    style:
                                        GoogleFonts.caveatBrush(fontSize: 300),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter:
                      MiddlePainter(calcDegree, Color.fromRGBO(255, 111, 0, 1)),
                  child: Container(
                    height: 175,
                    width: c.maxWidth,
                    decoration: ShapeDecoration(
                        shape: MiddleShapePainter(0, calcDegree)),
                    child: Material(
                      color: Colors.transparent,
                      shape: MiddleShapePainter(0, calcDegree),
                      child: InkWell(
                        onTap: () =>
                            AppReview.requestReview.then((value) => {}),
                        customBorder: MiddleShapePainter(0, calcDegree),
                        child: Container(
                          margin: EdgeInsets.only(
                              top: distanceOffset, bottom: distanceOffset),
                          child: Transform.rotate(
                            //angle: calcDegree * pi / 180 * -1,
                            angle: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "Bewerten",
                                    textAlign: TextAlign.center,
                                    style:
                                        GoogleFonts.caveatBrush(fontSize: 300),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter: BottomPainter(calcDegree, Colors.deepOrange),
                  child: Container(
                    height: 175,
                    width: c.maxWidth,
                    decoration: ShapeDecoration(
                        shape: BottomShapePainter(0, calcDegree)),
                    child: Material(
                      color: Colors.transparent,
                      shape: BottomShapePainter(0, calcDegree),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => Licenses())),
                        customBorder: BottomShapePainter(0, calcDegree),
                        child: Container(
                          margin: EdgeInsets.only(
                              top: distanceOffset, bottom: distanceOffset),
                          child: Transform.rotate(
                            //angle: calcDegree * pi / 180 * -1,
                            angle: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    "about",
                                    textAlign: TextAlign.center,
                                    style:
                                        GoogleFonts.caveatBrush(fontSize: 300),
                                  ).tr(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

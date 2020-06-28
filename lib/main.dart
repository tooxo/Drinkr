import 'dart:async';
import 'dart:ui';
import 'dart:math';

import 'package:SaufApp/ad.dart';
import 'package:SaufApp/setting.dart';
import 'package:SaufApp/shapes.dart';
import 'package:SaufApp/types.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom.dart';
import 'name_select.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final licenseGFont = await rootBundle.loadString("assets/licenses/OFL.txt");
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseGFont);
    final licenseTSwitch =
        await rootBundle.loadString("assets/licenses/TOGGLE_SWITCH.txt");
    yield LicenseEntryWithLineBreaks(["toggle_switch"], licenseTSwitch);
    final licenseIcon =
        await rootBundle.loadString("assets/licenses/flaticon.txt");
    yield LicenseEntryWithLineBreaks(["icons (flaticon)"], licenseIcon);
  });
  runApp(EasyLocalization(
    supportedLocales: [
      // Locale('en', 'US'),
      Locale('de', 'DE')
    ],
    path: 'assets/i18n',
    // fallbackLocale: Locale('en', 'US'),
    useOnlyLangCode: true,
    preloaderColor: Color.fromRGBO(255, 111, 0, 1),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      title: 'Saufapp',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  Timer t;

  void _launch(context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (Route<dynamic> route) => route is MyHomePage);
  }

  @override
  void initState() {
    super.initState();
    t = Timer(Duration(seconds: 3), () {
      _launch(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color.fromRGBO(255, 111, 0, 1),
      body: FlatButton(
          onPressed: () {
            if (this.t.isActive) {
              this.t.cancel();
            }
            this._launch(context);
          },
          child: Center(
              child: Text(
            "Gehe verantwortungsvoll mit Alkohol um. Wir übernehmen keine Haftung, also übertreibt es nicht!",
            style: GoogleFonts.caveatBrush(
              textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 35),
            ),
            textAlign: TextAlign.center,
          ))),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showAd = false;
  double offsetY = 0;

  final int degree = 5;

  BannerAd bannerAd;

  @override
  void initState() {
    super.initState();
    adProve(true);
  }

  Future<void> adProve(init) async {
    bool value = await shouldShowAds();
    if (value) {
      if (init) {
        await FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
      }
      this.showAd = true;
    } else {
      this.showAd = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 111, 0, 1),
      body: LayoutBuilder(builder: (context, boxConstraints) {
        double calcDegree = (atan((boxConstraints.maxHeight * 0.5 * 0.1) /
                    boxConstraints.maxWidth) *
                180) /
            pi;
        double distanceOffset =
            (boxConstraints.maxWidth * sin((calcDegree * pi / 180))) /
                sin(((90 - calcDegree) * pi) / 180);
        return Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                height: boxConstraints.maxHeight * 0.5,
                width: boxConstraints.maxWidth,
                decoration: ShapeDecoration(
                    shape: TopShapePainter(calcDegree),
                    color: Colors.deepOrange),
                child: Material(
                  color: Colors.transparent,
                  shape: TopShapePainter(calcDegree),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NameSelect(GameType.values))),
                    customBorder: TopShapePainter(calcDegree),
                    child: Container(
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Transform.rotate(
                              angle: calcDegree * pi / 180 * -1,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "mainMenuButtonNormal",
                                    style: GoogleFonts.caveatBrush(
                                      fontSize: 2000,
                                    ),
                                  ).tr(),
                                  Text(
                                    "Starte direkt ins Spiel!",
                                    style: GoogleFonts.caveatBrush(
                                      fontSize: 500,
                                    ),
                                  ).tr(),
                                ],
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: (boxConstraints.maxHeight * 0.5) - distanceOffset,
              child: Container(
                  height: boxConstraints.maxHeight * 0.35,
                  width: boxConstraints.maxWidth,
                  decoration: ShapeDecoration(
                      shape: MiddleShapePainter(
                          boxConstraints.maxHeight * 0.5 - distanceOffset,
                          calcDegree),
                      color: Colors.purple),
                  child: Material(
                    color: Colors.transparent,
                    shape: MiddleShapePainter(0, calcDegree),
                    child: InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Custom())),
                        customBorder: MiddleShapePainter(0, calcDegree),
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Transform.rotate(
                                  angle: calcDegree * pi / 180 * -1,
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Transform.rotate(
                                            angle: 45 * pi / 180,
                                          ),
                                          Text(
                                            "mainMenuButtonCustom",
                                            style: GoogleFonts.caveatBrush(
                                                fontSize: 2000),
                                          ).tr(),
                                        ],
                                      ),
                                      Text(
                                        "Spiel nach deinen eigenen Regeln!",
                                        style: GoogleFonts.caveatBrush(
                                            fontSize: 500),
                                      ).tr(),
                                    ],
                                  ),
                                )),
                          ),
                        )),
                  )),
            ),
            Positioned(
              top: boxConstraints.maxHeight * 0.85 - distanceOffset * 2,
              child: Container(
                height: boxConstraints.maxHeight * 0.15 + distanceOffset * 2,
                width: boxConstraints.maxWidth,
                decoration: ShapeDecoration(
                    color: Colors.blue,
                    shape: BottomShapePainter(
                        boxConstraints.maxHeight * 0.85 - distanceOffset * 2,
                        calcDegree)),
                child: Material(
                  color: Colors.transparent,
                  shape: BottomShapePainter(0, calcDegree),
                  child: InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Settings())),
                    customBorder: BottomShapePainter(0, calcDegree),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Transform.rotate(
                          angle: calcDegree * pi / 180 * -1,
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    "settings",
                                    style: GoogleFonts.caveatBrush(
                                      textStyle: TextStyle(
                                          color: Colors.black, fontSize: 2000),
                                    ),
                                  ).tr(),
                                ],
                              ),
                              /*Text(
                                "Stelle die Sprache ein, bewerte uns oder melde Fehler!",
                                style: GoogleFonts.caveatBrush(
                                  textStyle: TextStyle(
                                      color: Colors.black, fontSize: 600),
                                ),
                              ).tr(),*/
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              child: Container(
                decoration: ShapeDecoration(
                    shape: DividerPainter(
                        boxConstraints.maxHeight * .5, calcDegree),
                    // color: Colors.white,
                    color: Colors.transparent),
              ),
            ),
            Positioned(
              child: Container(
                decoration: ShapeDecoration(
                    shape: DividerPainter(
                        boxConstraints.maxHeight * 0.85 - distanceOffset,
                        calcDegree),
                    // color: Colors.white,
                    color: Colors.transparent),
              ),
            ),
          ],
        );
      }),
    );
  }
}

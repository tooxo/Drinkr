import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'menus/name_select.dart';

/// this is used to create a "no-ad" version, if set to false.
/// the seemingly random variable naming is used to identify it
/// during build with tools like unix's sed.
const bool ADS_ENABLED_BUQF1EVY = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await EasyLocalization.ensureInitialized();

  runApp(EasyLocalization(
    supportedLocales: [Locale('en', 'US'), Locale('de', 'DE')],
    path: 'assets/i18n',
    fallbackLocale: Locale('en', 'US'),
    useOnlyLangCode: true,
    // preloaderColor: Color.fromRGBO(255, 111, 0, 1),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return MaterialApp(
      title: 'Drinkr',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        /*unselectedWidgetColor: Colors.white,*/
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
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late Timer t;

  void _launch(context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => NameSelect()),
        (Route<dynamic> route) => route is NameSelect);
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
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 111, 0, 1),
      body: TextButton(
          onPressed: () {
            if (this.t.isActive) {
              this.t.cancel();
            }
            this._launch(context);
          },
          child: Center(
              child: Text(
            "splash",
            style: GoogleFonts.caveatBrush(
              textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 35),
            ),
            textAlign: TextAlign.center,
          ).tr())),
    );
  }
}
import 'dart:ui';

import 'package:drinkr/utils/ad.dart';
import 'package:drinkr/utils/spotify_api.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'menus/name_select.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

const bool adsEnabled =
    bool.fromEnvironment("ADS_ENABLED", defaultValue: false);

void main() async {
  checkAdVariables();
  WidgetsFlutterBinding.ensureInitialized();

  LicenseRegistry.addLicense(() async* {
    final licenseGFont = await rootBundle.loadString("assets/licenses/OFL.txt");
    yield LicenseEntryWithLineBreaks(['google_fonts'], licenseGFont);
    final licenseIcon =
        await rootBundle.loadString("assets/licenses/flaticon.txt");
    yield LicenseEntryWithLineBreaks(["icons (flaticon)"], licenseIcon);
  });
  await Hive.initFlutter("storage");

  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(PlaylistAdapter());

  await Hive.openBox<Song>('spotify_songs');
  await Hive.openBox<Playlist>('spotify_playlists');

  await EasyLocalization.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }

  runApp(EasyLocalization(
    supportedLocales: [
      Locale('en', 'US'),
      Locale('de', 'DE'),
      // Locale('es', 'ES'),
    ],
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
      ),
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      locale: context.locale,
      home: NameSelect(),
    );
  }
}

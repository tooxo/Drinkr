import 'package:flutter/material.dart';

class CustomIcons {
  static const String? _kFontPkg = null;

  // Brand Icons
  static const IconData spotify =
      IconData(0xe803, fontFamily: "BrandIcons", fontPackage: null);

  // other icons
  static const IconData trash =
      IconData(0xe804, fontFamily: 'OtherIcons', fontPackage: _kFontPkg);
  static const IconData noad =
      IconData(0xe806, fontFamily: 'OtherIcons', fontPackage: _kFontPkg);

  static const IconData dif_high =
      IconData(0xe800, fontFamily: 'AlcoholIcons', fontPackage: _kFontPkg);
  static const IconData dif_low =
      IconData(0xe801, fontFamily: 'AlcoholIcons', fontPackage: _kFontPkg);
  static const IconData dif_med =
      IconData(0xe802, fontFamily: 'AlcoholIcons', fontPackage: _kFontPkg);
  static const IconData shot =
      IconData(0xe805, fontFamily: 'AlcoholIcons', fontPackage: _kFontPkg);

  static const IconData game_mode_standard =
      IconData(0xe807, fontFamily: 'GameModeIcons', fontPackage: _kFontPkg);
  static const IconData game_mode_party =
      IconData(0xe809, fontFamily: 'GameModeIcons', fontPackage: _kFontPkg);
  static const IconData game_mode_song =
      IconData(0xe80c, fontFamily: 'GameModeIcons', fontPackage: _kFontPkg);
  static const IconData game_mode_custom =
      IconData(0xe80d, fontFamily: 'GameModeIcons', fontPackage: _kFontPkg);
  static const IconData game_mode_quiz =
      IconData(0xe810, fontFamily: 'GameModeIcons', fontPackage: _kFontPkg);

  static const IconData spotify_outline =
      IconData(0xe812, fontFamily: 'SettingsIcons', fontPackage: _kFontPkg);
  static const IconData no_ad =
      IconData(0xe813, fontFamily: 'SettingsIcons', fontPackage: _kFontPkg);
  static const IconData translation =
      IconData(0xe814, fontFamily: 'SettingsIcons', fontPackage: _kFontPkg);
  static const IconData refresh =
      IconData(0xe816, fontFamily: 'SettingsIcons', fontPackage: _kFontPkg);
}

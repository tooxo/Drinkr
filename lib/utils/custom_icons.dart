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
}

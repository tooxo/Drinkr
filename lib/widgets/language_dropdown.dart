import 'dart:ui';

import 'package:drinkr/main.dart';
import 'package:drinkr/menus/name_select.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({Key? key}) : super(key: key);

  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  bool extended = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              extended = !extended;
            });
          },
          child: Image.asset(
            "assets/flags/" +
                EasyLocalization.of(context)!.currentLocale!.languageCode +
                ".png",
            height: 40,
          ),
        ),
        !extended
            ? Container()
            : Column(
                children: [
                  for (Locale l
                      in EasyLocalization.of(context)?.supportedLocales.where(
                                (element) =>
                                    element !=
                                    EasyLocalization.of(context)!.currentLocale,
                              ) ??
                          [])
                    InkWell(
                      onTap: () async {
                        await EasyLocalization.of(context)!.setLocale(l);
                        setState(() {
                          extended = false;
                        });
                      },
                      child: Image.asset(
                        "assets/flags/" + l.languageCode + ".png",
                        height: 40,
                      ),
                    )
                ],
              ),
      ],
    );
  }
}

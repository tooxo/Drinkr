import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomAlert extends StatelessWidget {
  final String titleTranslationKey;
  final String textTranslationKey;
  final String buttonTextTranslationKey;
  final Color backgroundColor;
  final Color textColor;

  CustomAlert({
    required this.titleTranslationKey,
    required this.textTranslationKey,
    required this.buttonTextTranslationKey,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: AlertDialog(
        title: Text(
          titleTranslationKey,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(color: textColor),
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
        ).tr(),
        content: Text(
          textTranslationKey,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(color: textColor),
            fontSize: 25,
          ),
        ).tr(),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          TextButton(
            child: Text(
              buttonTextTranslationKey,
              style: GoogleFonts.nunito(
                color: textColor,
                fontSize: 20,
              ),
            ).tr(),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}

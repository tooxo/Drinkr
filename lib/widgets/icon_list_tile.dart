import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IconListTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  final Color color;
  final double iconSize;

  final Function() onTap;

  final AutoSizeGroup? asg;

  IconListTile({
    required this.iconData,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.asg,
    this.iconSize = 60,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: 70, maxWidth: 70, maxHeight: 70, minHeight: 70),
            child: Icon(
              iconData,
              color: color,
              size: iconSize,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.contain,
                  child: AutoSizeText(
                    title,
                    minFontSize: 25,

                    maxFontSize: 35,
                    group: asg,
                    style: GoogleFonts.nunito(
                      color: color,
                      // fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(color: color, fontSize: 15),
                  maxLines: 3,
                  softWrap: true,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

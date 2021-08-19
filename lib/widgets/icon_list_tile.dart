import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IconListTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final String subtitle;
  final Color color;
  final double iconSize;

  final Function() onTap;

  IconListTile({
    required this.iconData,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconSize = 70,
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
              minWidth: 80,
              maxWidth: 80,
              maxHeight: 80
            ),
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
                  child: Text(
                    title,
                    style: GoogleFonts.nunito(
                      color: color,
                      fontSize: 30,
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

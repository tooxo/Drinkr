import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:show_up_animation/show_up_animation.dart';

class TextWidget extends StatelessWidget {
  final String displayedText;

  const TextWidget(this.displayedText);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShowUpAnimation(
        delayStart: Duration(seconds: 0),
        child: AutoSizeText(
          '''$displayedText''',
          style: GoogleFonts.caveatBrush(
              color: Colors.black, fontSize: 1000, fontWeight: FontWeight.w600),
          maxLines: 5,
          textAlign: TextAlign.center,
          maxFontSize: 60,
          softWrap: true,
          group: AutoSizeGroup(),
        ),
      ),
    );
  }
}
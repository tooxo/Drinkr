import 'package:flutter/material.dart';

enum GradientDirection { HORIZONTAL, VERTICAL }

class TwoColorGradient extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Widget child;
  final GradientDirection direction;

  const TwoColorGradient(
      {Key key,
      this.color1,
      this.color2,
      this.child,
      this.direction = GradientDirection.HORIZONTAL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: direction == GradientDirection.HORIZONTAL
                ? Alignment.centerLeft
                : Alignment.topCenter,
            end: direction == GradientDirection.HORIZONTAL
                ? Alignment.centerRight
                : Alignment.bottomCenter,
            // 10% of the width, so there are ten blinds.
            colors: <Color>[color1, color2],
            // red to yellow
            tileMode: TileMode.mirror),
      ),
      child: child,
    );
  }
}

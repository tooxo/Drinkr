import 'package:flutter/material.dart';

enum GradientDirection { HORIZONTAL, VERTICAL }

class TwoColorGradient extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Widget child;
  final GradientDirection direction;
  final double roundness;

  const TwoColorGradient(
      {Key key,
      this.color1,
      this.color2,
      this.child,
      this.roundness = 0,
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
            colors: <Color>[color1, color2],
            tileMode: TileMode.mirror),
        borderRadius: BorderRadius.all(Radius.circular(roundness)),
      ),
      child: child,
    );
  }
}

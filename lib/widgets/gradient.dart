import 'package:flutter/material.dart';

enum GradientDirection { horizontal, vertical }

class ColorGradient extends StatelessWidget {
  final List<Color> colors;
  final Widget? child;
  final GradientDirection direction;
  final double roundness;

  const ColorGradient({
    Key? key,
    required this.colors,
    this.child,
    this.roundness = 0,
    this.direction = GradientDirection.horizontal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: direction == GradientDirection.horizontal
              ? Alignment.centerLeft
              : Alignment.topCenter,
          end: direction == GradientDirection.horizontal
              ? Alignment.centerRight
              : Alignment.bottomCenter,
          colors: colors,
          tileMode: TileMode.mirror,
        ),
        borderRadius: BorderRadius.all(Radius.circular(roundness)),
      ),
      child: child,
    );
  }
}

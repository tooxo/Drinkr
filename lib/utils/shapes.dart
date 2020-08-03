import 'dart:math';

import 'package:flutter/material.dart';

class TopPainter extends CustomPainter {
  final double degrees;
  final Color color;

  TopPainter(this.degrees, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double offsetB = (size.width * sin((degrees * pi) / 180.0)) /
        sin(((90 - degrees) * pi) / 180.0);

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height - offsetB)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0);
    Paint p = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class TopShapePainter extends ShapeBorder {
  final double degrees;

  TopShapePainter(this.degrees);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return this.getPath(rect, textDirection: textDirection);
  }

  Path getPath(Rect rect, {TextDirection textDirection}) {
    double offsetB = (rect.width * sin((degrees * pi) / 180.0)) /
        sin(((90 - degrees) * pi) / 180.0);

    return Path()
      ..moveTo(0, 0)
      ..lineTo(0, rect.height)
      ..lineTo(rect.width, rect.height - offsetB)
      ..lineTo(rect.width, 0)
      ..lineTo(0, 0);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return this.getPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    Paint paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(getInnerPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    // TODO: implement scale
    throw UnimplementedError();
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);
}

class MiddlePainter extends CustomPainter {
  final double degrees;
  final Color color;

  MiddlePainter(this.degrees, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double offsetB = (size.width * sin((degrees * pi) / 180.0)) /
        sin(((90 - degrees) * pi) / 180.0);
    Path path = Path()
      ..moveTo(0, offsetB)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height - offsetB)
      ..lineTo(size.width, 0)
      ..lineTo(0, offsetB);
    Paint p = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MiddleClipper extends CustomClipper<Path> {
  final double degrees;

  const MiddleClipper(this.degrees);

  @override
  Path getClip(Size size) {
    double offsetB = (size.width * sin((degrees * pi) / 180.0)) /
        sin(((90 - degrees) * pi) / 180.0);
    return Path()
      ..moveTo(0, offsetB)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height - offsetB)
      ..lineTo(size.width, 0)
      ..lineTo(0, offsetB);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class BottomClipper extends CustomClipper<Path> {
  final double degrees;

  const BottomClipper(this.degrees);

  @override
  Path getClip(Size size) {
    double offsetB = (size.width * sin((degrees * pi) / 180.0)) /
        sin(((90 - degrees) * pi) / 180.0);
    return Path()
      ..moveTo(0, offsetB)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, offsetB);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class MiddleShapePainter extends ShapeBorder {
  final double offsetY;
  final double degrees;

  MiddleShapePainter(this.offsetY, this.degrees);

  Path getPath(Rect rect, {TextDirection textDirection}) {
    double offsetB = (rect.width * sin((degrees * pi) / 180.0)) /
        sin(((90 - degrees) * pi) / 180.0);
    return Path()
      ..moveTo(0, offsetY + offsetB)
      ..lineTo(0, rect.height + offsetY)
      ..lineTo(rect.width, rect.height - offsetB + offsetY)
      ..lineTo(rect.width, offsetY)
      ..lineTo(0, offsetY + offsetB);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    Paint paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(getInnerPath(rect), paint);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return getPath(rect);
  }

  @override
  ShapeBorder scale(double t) {
    // TODO: implement scale
    throw UnimplementedError();
  }
}

class BottomShapePainter extends MiddleShapePainter {
  BottomShapePainter(double offsetY, double degrees) : super(offsetY, degrees);

  @override
  Path getPath(Rect rect, {TextDirection textDirection}) {
    double offsetB = (rect.width * sin((degrees * pi) / 180.0)) /
        sin(((90 - degrees) * pi) / 180.0);
    return Path()
      ..moveTo(0, offsetY + offsetB)
      ..lineTo(0, rect.height + offsetY)
      ..lineTo(rect.width, rect.height + offsetY)
      ..lineTo(rect.width, offsetY)
      ..lineTo(0, offsetB + offsetY);
  }
}

class DividerPainter extends ShapeBorder {
  final double offsetY;
  final double degree;

  DividerPainter(this.offsetY, this.degree);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);

  Path getPath(Rect rect) {
    double offsetB = (rect.width * sin((degree * pi) / 180.0)) /
        sin(((90 - degree) * pi) / 180.0);
    return Path()
      ..moveTo(0, this.offsetY)
      ..lineTo(rect.width, this.offsetY - offsetB);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getPath(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return getPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawPath(getInnerPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    // TODO: implement scale
    throw UnimplementedError();
  }
}

class BottomPainter extends CustomPainter {
  final double degrees;
  final Color color;

  BottomPainter(this.degrees, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double offsetB = (size.width * sin((degrees * pi) / 180.0)) /
        sin(((90 - degrees) * pi) / 180.0);
    Path path = Path()
      ..moveTo(0, offsetB)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(0, offsetB);
    Paint p = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

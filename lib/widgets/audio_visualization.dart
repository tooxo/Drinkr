import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

class SoundData {
  int channels;
  int sampleRate;
  int samplesPerPixel;
  int bits;
  int length;
  List<int> data;

  SoundData(String jsonData) {
    assert(jsonData != null);
    assert(jsonData != "{}");
    dynamic jsonObject;
    try {
      jsonObject = json.decode(jsonData);
    } on FormatException {
      throw Exception("Error while parsing.");
    }
    channels = jsonObject["channels"];
    sampleRate = jsonObject["sample_rate"];
    samplesPerPixel = jsonObject["samples_per_pixel"];
    bits = jsonObject["bits"];
    length = jsonObject["length"];
    List<dynamic> temp = jsonObject["data"];
    data = [];
    for (int i = 0; i < temp.length; i++) {
      data.add(temp[i] as int);
    }
  }

  Size savedSize;
  Path savedPath;

  Path path(Size size, {drawRect = false}) {
    if (size == savedSize && savedPath != null) {
      return savedPath;
    }
    savedPath = _path(data, size, drawRect: drawRect);
    savedSize = size;
    return savedPath;
  }

  Path _path(List<int> samples, Size size, {drawRect = false}) {
    final middle = size.height / 2;

    List<double> minPoints = [];
    List<double> maxPoints = [];

    int barNum = 180;

    for (var _i = 0, _len = samples.length; _i < _len; _i++) {
      var d = samples[_i];
      if (_i % 2 != 0) {
        minPoints.add(d.toDouble());
      } else {
        maxPoints.add(d.toDouble());
      }
    }

    List<List<double>> output = [];
    int step = (minPoints.length / barNum).ceil();
    double aMax = 0;
    int aMaxA = 0;
    double aMin = 0;
    int aMinA = 0;
    for (int _i = 0; _i < maxPoints.length; _i++) {
      aMax += maxPoints.elementAt(_i);
      aMaxA += 1;
      aMin += minPoints.elementAt(_i);
      aMinA += 1;
      if (_i % step == 0) {
        output.add([(aMax / aMaxA), (aMin / aMinA)]);
        aMax = 0;
        aMaxA = 0;
        aMin = 0;
        aMinA = 0;
      }
    }

    double max0 = 0;
    double min1 = 0;
    for (List<double> a in output) {
      max0 = max(a[0], max0);
      min1 = min(a[1], min1);
    }

    double scaleFactor = size.height * 0.4 / max(max0, min1.abs());

    final path = Path();

    final t = (size.width / barNum);
    for (int _j = 1; _j < output.length; _j++) {
      if (drawRect) {
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(t * _j - 1.25, middle + output[_j][0] * scaleFactor),
              Offset(t * _j + 1.25, middle + output[_j][1] * scaleFactor),
            ),
            Radius.circular(24),
          ),
        );
      } else {
        path.moveTo(t * _j, middle + output[_j][0] * scaleFactor);
        path.lineTo(t * _j, middle + output[_j][1] * scaleFactor);
      }
    }

    path.close();
    return path;
  }
}

class WaveformClipper extends CustomClipper<Path> {
  WaveformClipper(this.data);

  final SoundData data;

  @override
  Path getClip(Size size) {
    return data.path(size, drawRect: true);
  }

  @override
  bool shouldReclip(WaveformClipper oldClipper) {
    if (data != oldClipper.data) {
      return true;
    }
    return false;
  }
}

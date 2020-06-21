/*
MIT License

Copyright (c) 2019 Pramod Joshi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */

//Credit : @Eugene (https://stackoverflow.com/questions/56340682/flutter-equvalent-android-toggle-switch

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef OnToggle = Future<bool> Function(int index);

class ToggleSwitch extends StatefulWidget {
  final Color activeBgColor;
  final Color activeTextColor;
  final Color inactiveBgColor;
  final Color inactiveTextColor;
  final List<String> labels;
  final double cornerRadius;
  final OnToggle onToggle;
  final int initialLabelIndex;
  final double minWidth;
  final double minHeight;
  final List<IconData> icons;
  final List<Color> activeColors;

  /// [onToggle] is a callback made when the user attempts
  /// to toggle the switch. You can reject the toggle by
  /// returning false, otherwise return true.
  ///
  /// [minHeight] controls the minimum height of the switch. The default
  /// value is 40. Pass [null] to allow the switch to size based on its content.
  ///
  ToggleSwitch({
    Key key,
    @required this.activeBgColor,
    @required this.activeTextColor,
    @required this.inactiveBgColor,
    @required this.inactiveTextColor,
    @required this.labels,
    this.onToggle,
    this.cornerRadius = 8.0,
    this.initialLabelIndex = 0,
    this.minWidth = 72,
    this.minHeight = 40,
    this.icons,
    this.activeColors,
  }) : super(key: key);

  @override
  ToggleSwitchState createState() => ToggleSwitchState();
}

class ToggleSwitchState extends State<ToggleSwitch>
    with AutomaticKeepAliveClientMixin<ToggleSwitch> {
  int current;

  @override
  void initState() {
    current = widget.initialLabelIndex;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, c) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        child: Container(
          height: widget.minHeight,
          color: widget.activeBgColor,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.labels.length * 2 - 1,
              (index) {
                final active = index ~/ 2 == current;
                final textColor =
                    active ? widget.activeTextColor : widget.inactiveTextColor;
                if (index % 2 == 1) {
                  return Container();
                } else {
                  final activeDivider = active;
                  return GestureDetector(
                    onTap: () => _handleOnTap(index ~/ 2),
                    child: Container(
                      width: c.maxWidth / (widget.labels.length),
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                      alignment: Alignment.center,
                      color: activeDivider
                          ? widget.activeBgColor
                          : widget.inactiveBgColor,
                      child: widget.icons == null
                          ? Text(widget.labels[index ~/ 2],
                              style: GoogleFonts.caveatBrush(color: textColor,
                              fontSize: 17))
                          : Row(
                              children: <Widget>[
                                Icon(widget.icons[index ~/ 2],
                                    color: textColor, size: 17.0),
                                Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(widget.labels[index ~/ 2],
                                        style: GoogleFonts.caveatBrush(
                                            color: textColor)))
                              ],
                            ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleOnTap(int index) async {
    bool allowToggle = true;
    if (widget.onToggle != null) {
      allowToggle = await widget.onToggle(index);
    }

    setState(() {
      if (allowToggle) current = index;
    });
  }

  void setIndex(int index) {
    setState(() => current = index);
  }
}

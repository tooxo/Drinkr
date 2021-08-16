library custom_switch;

import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor = Colors.grey.withOpacity(.4);

  final Duration duration = Duration(milliseconds: 200);

  final Color activeTextColor;
  final Color inactiveTextColor;

  final bool enabled;

  CustomSwitch(
      {required this.value,
      required this.onChanged,
      required this.activeColor,
      required this.enabled,
      this.activeTextColor = Colors.white70,
      this.inactiveTextColor = Colors.white70});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              if (onChanged != null) {
                onChanged!(!value);
              }
            }
          : null,
      child: AnimatedContainer(
        width: 50.0,
        height: 25.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: value ? activeColor : inactiveColor),
        duration: duration,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: AnimatedAlign(
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  duration: duration,
                  child: Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: enabled ? Colors.white : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

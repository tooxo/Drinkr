library custom_switch;


import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color inactiveColor = Colors.grey.withOpacity(.4);

  final Color activeTextColor;
  final Color inactiveTextColor;

  final bool enabled;

  final GlobalKey<CustomSwitchState>? key;

  CustomSwitch(
      {required this.value,
      required this.onChanged,
      required this.activeColor,
      required this.key,
      required this.enabled,
      this.activeTextColor = Colors.white70,
      this.inactiveTextColor = Colors.white70})
      : super(key: key);

  @override
  CustomSwitchState createState() => CustomSwitchState();
}

class CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late Animation _colorAnimation;
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _circleAnimation = AlignmentTween(
      begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
      end: widget.value ? Alignment.centerLeft : Alignment.centerRight,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ),
    );
    _colorAnimation = ColorTween(
      begin: widget.value ? widget.activeColor : widget.inactiveColor,
      end: widget.value ? widget.inactiveColor : widget.activeColor,
    ).animate(
      controller,
    );

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.enabled
              ? () {
                  if (controller.isCompleted) {
                    controller.reverse();
                  } else {
                    controller.forward();
                  }
                  if (widget.onChanged != null) {
                    widget.value == false
                        ? widget.onChanged!(true)
                        : widget.onChanged!(false);
                  }
                }
              : null,
          child: Container(
            width: 50.0,
            height: 25.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: _colorAnimation.value),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Align(
                      alignment: _circleAnimation.value,
                      child: Container(
                        width: 22.0,
                        height: 22.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.enabled
                              ? Colors.white
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

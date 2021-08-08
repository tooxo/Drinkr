import 'package:flutter/material.dart';

class CustomRadioWidget extends StatefulWidget {
  final int value;
  final int groupValue;
  final ValueChanged<int> onChanged;
  final double height;
  final bool enabled;

  CustomRadioWidget(
      {required this.value,
      required this.groupValue,
      required this.onChanged,
      required this.enabled,
      this.height = 20});

  @override
  State<StatefulWidget> createState() => _CustomRadioWidgetState();
}

class _CustomRadioWidgetState extends State<CustomRadioWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    controller.reset();
    animation = Tween(
            begin: 0.0,
            end: widget.value == widget.groupValue ? widget.height - 8.0 : 0.0)
        .animate(controller)
          ..addListener(() {
            setState(() {});
          });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          controller.reset();
          double begin =
              widget.value == widget.groupValue ? widget.height - 8.0 : 0.1;
          double end = widget.height - 8.0;

          animation = Tween(begin: begin, end: end).animate(controller)
            ..addListener(() {
              setState(() {});
            });
          widget.onChanged(widget.value);
        });

        controller.forward();
      },
      child: Container(
        height: widget.height,
        width: widget.height,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Center(
          child: Container(
            height:
                animation.value == 0.0 ? widget.height - 8 : animation.value,
            width: animation.value == 0.0 ? widget.height - 8 : animation.value,
            decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: widget.value == widget.groupValue
                  ? widget.enabled
                      ? Colors.black
                      : Colors.grey
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

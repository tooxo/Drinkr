import 'package:flutter/material.dart';

class CustomRadioWidget<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final double height;
  final bool enabled;

  CustomRadioWidget(
      {required this.value,
      required this.groupValue,
      required this.onChanged,
      required this.enabled,
      this.height = 20});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: AnimatedContainer(
        height: height,
        width: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value == groupValue ? Colors.transparent : Colors.white,
          border: Border.all(
            color: Colors.white,
            width: value == groupValue ? 3 : 1,
          ),
        ),
        duration: Duration(milliseconds: 200),
        child: Center(
          child: AnimatedContainer(
            decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: value == groupValue
                  ? enabled
                      ? Colors.black.withOpacity(.4)
                      : Colors.grey
                  : Colors.white,
            ),
            duration: Duration.zero,
            child: AnimatedContainer(
              height: value == groupValue ? height - 6 : height - 2,
              width: value == groupValue ? height - 6 : height - 2,
              duration: Duration.zero,
            ),
          ),
        ),
      ),
    );
  }
}

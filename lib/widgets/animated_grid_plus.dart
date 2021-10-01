import 'package:drinkr/widgets/external/animated_grid.dart';
import 'package:flutter/material.dart';

class AnimatedGridPlus<T> extends StatelessWidget {
  const AnimatedGridPlus({
    Key? key,
    required this.itemHeight,
    required this.items,
    required this.keyBuilder,
    required this.builder,
    this.finalWidget,
    this.columns = 2,
    this.duration = const Duration(milliseconds: 750),
    this.curve = Curves.elasticOut,
  }) : super(key: key);

  final List<T> items;

  final Key Function(T item) keyBuilder;

  final Function(BuildContext, T, AnimatedGridDetails) builder;

  final int columns;

  final double itemHeight;

  final Duration duration;

  final Curve curve;

  final Widget? finalWidget;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext c, BoxConstraints con) {
        final additional = finalWidget != null ? 1 : 0;
        final rows = ((items.length + additional) / columns).ceil();
        return SizedBox(
          height: rows * itemHeight,
          width: con.maxWidth,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              for (int i = 0; i < items.length; i++)
                Builder(
                  key: keyBuilder(items[i]),
                  builder: (BuildContext context) {
                    int row = (i / columns).floor();
                    int column = i % columns;

                    double offsetX = con.maxWidth / columns * column;
                    double offsetY = row * itemHeight;

                    final Offset offset = Offset(
                      offsetX,
                      offsetY,
                    );

                    return TweenAnimationBuilder(
                      tween: Tween(end: offset),
                      child: SizedBox(
                        height: itemHeight,
                        width: con.maxWidth / columns,
                        child: builder(
                          context,
                          items[i],
                          AnimatedGridDetails(
                            index: i,
                            columnIndex: column,
                            rowIndex: row,
                            columns: columns,
                            rows: rows,
                          ),
                        ),
                      ),
                      builder:
                          (BuildContext context, Offset offset, Widget? child) {
                        return Transform.translate(
                          offset: offset,
                          child: child,
                        );
                      },
                      duration: duration,
                    );
                  },
                ),
              Builder(
                key: finalWidget?.key,
                builder: (BuildContext context) {
                  int row = (items.length / columns).floor();
                  int column = items.length % columns;

                  double offsetX = con.maxWidth / columns * column;
                  double offsetY = row * itemHeight;

                  final Offset offset = Offset(
                    offsetX,
                    offsetY,
                  );

                  return TweenAnimationBuilder(
                    tween: Tween(end: offset),
                    child: SizedBox(
                      height: itemHeight,
                      width: con.maxWidth / columns,
                      child: finalWidget,
                    ),
                    builder:
                        (BuildContext context, Offset offset, Widget? child) {
                      return Transform.translate(
                        offset: offset,
                        child: child,
                      );
                    },
                    duration: duration,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:drinkr/widgets/custom_radio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class RadioProgressIndicator extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int initialValue;
  final bool enabled;

  RadioProgressIndicator(
      {required this.onChanged, this.initialValue = 0, this.enabled = true});

  static const _kFontFam = 'DifficultyIcons';
  static const String? _kFontPkg = null;

  static const IconData dif_hard =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dif_mid =
      IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData dif_easy =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  @override
  State<StatefulWidget> createState() => _RadioProgressIndicatorState();
}

class _RadioProgressIndicatorState extends State<RadioProgressIndicator>
    with SingleTickerProviderStateMixin {
  late int groupValue;

  late AnimationController controller;
  late Animation<double> animation;

  void updateGroupValue(int newVal) {
    if (groupValue == newVal || !widget.enabled) return;
    setState(() {
      controller.reset();
      animation = Tween<double>(begin: groupValue * .5, end: newVal * .5)
          .animate(controller)
            ..addListener(() {
              setState(() {});
            });
      groupValue = newVal;
    });

    controller.forward();
    widget.onChanged(newVal);
  }

  @override
  void initState() {
    super.initState();
    groupValue = widget.initialValue;
    controller = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);

    animation = Tween(begin: 0.0, end: groupValue * .5).animate(controller);
  }

  Color getColor(int i) {
    if (i == groupValue) return Colors.white;
    return Colors.white.withOpacity(0.6);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        children: [
          Container(
            height: 85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: InkWell(
                      onTap: () {
                        updateGroupValue(0);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                RadioProgressIndicator.dif_easy,
                                color: getColor(0),
                                size: 60,
                              ),
                              Text(
                                "difficultyLow",
                                style: GoogleFonts.nunito(
                                  color: getColor(0),
                                  fontSize: 18,
                                ),
                              ).tr()
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: InkWell(
                      onTap: () {
                        updateGroupValue(1);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            RadioProgressIndicator.dif_mid,
                            color: getColor(1),
                            size: 60,
                          ),
                          Text(
                            "difficultyMed",
                            style: GoogleFonts.nunito(
                              color: getColor(1),
                              fontSize: 18,
                            ),
                          ).tr()
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 1,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: InkWell(
                      onTap: () {
                        updateGroupValue(2);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                RadioProgressIndicator.dif_hard,
                                color: getColor(2),
                                size: 60,
                              ),
                              Text(
                                "difficultyHigh",
                                style: GoogleFonts.nunito(
                                  color: getColor(2),
                                  fontSize: 18,
                                ),
                              ).tr()
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: Container(
                    width: constraints.maxWidth / 2.0 - 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: LinearProgressIndicator(
                        value: animation.value * 2,
                        backgroundColor: Colors.white.withOpacity(.6),
                        minHeight: 3,
                        valueColor: AlwaysStoppedAnimation(
                            Colors.white.withOpacity(0.9)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    width: constraints.maxWidth / 2.0 - 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: LinearProgressIndicator(
                        value: animation.value * 2 - 1,
                        backgroundColor: Colors.white.withOpacity(0.6),
                        minHeight: 2,
                        valueColor: AlwaysStoppedAnimation(
                            Colors.white.withOpacity(0.9)),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (int i = 0; i < 3; i++)
                      CustomRadioWidget(
                          value: i,
                          enabled: widget.enabled,
                          groupValue: groupValue,
                          onChanged: updateGroupValue)
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

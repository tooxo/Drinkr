import 'dart:ui';

import 'package:drinkr/games/game_controller.dart';
import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/menus/game_mode.dart';
import 'package:drinkr/utils/player.dart';
import 'package:drinkr/widgets/custom_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:drinkr/utils/types.dart';
import 'package:drinkr/widgets/gradient.dart';
import 'package:drinkr/widgets/radio_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pedantic/pedantic.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class GameSelectTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<GameType> enabledGames;
  final ValueChanged<CurrentGameState> onGameStateChange;
  final BuildContext parentContext;
  final List<Player> players;
  final bool enabled;
  final List<Color> backgroundColors;

  GameSelectTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabledGames,
    required this.players,
    required this.onGameStateChange,
    required this.parentContext,
    required this.enabled,
    required this.backgroundColors,
  }) {
    assert(backgroundColors.length >= 2);
  }

  @override
  State<StatefulWidget> createState() => GameSelectTileState();
}

class GameSelectTileState extends State<GameSelectTile> {
  ExpandableController controller =
      ExpandableController(initialExpanded: false);

  int selectedDifficulty = 1;
  bool useAdultQuestions = true;

  ButtonState buttonState = ButtonState.idle;

  void startGame() async {
    if (!widget.enabled) {
      return;
    }
    widget.onGameStateChange(CurrentGameState.LOADING);
    GameController gameController = GameController(100, widget.enabledGames,
        widget.players, widget.parentContext, !useAdultQuestions);
    buttonState = ButtonState.loading;
    bool success = await gameController.prepare();
    if (!success) {
      buttonState = ButtonState.fail;
      widget.onGameStateChange(CurrentGameState.STOPPED);
      return;
    } else {
      unawaited(
        Future.delayed(Duration(milliseconds: 500)).then(
          (value) => widget.onGameStateChange(CurrentGameState.IN_GAME),
        ),
      );
    }

    DifficultyType difficultyType;
    switch (selectedDifficulty) {
      case 0:
        difficultyType = DifficultyType.EASY;
        break;
      case 1:
        difficultyType = DifficultyType.MEDIUM;
        break;
      case 2:
        difficultyType = DifficultyType.HARD;
        break;
      default:
        return;
    }

    await gameController.start(difficultyType);
    widget.onGameStateChange(CurrentGameState.STOPPED);
    buttonState = ButtonState.idle;
  }

  bool hasAdultGames() {
    return widget.enabledGames
        .map((e) => gameTypeToGameTypeClass(e))
        .map((e) => e.hasAdultQuestions)
        .toList()
        .contains(true);
  }

  bool adultSwitchEnabled() {
    return true;
  }

  void toggleAdultQuestions(bool _) {
    setState(() {
      useAdultQuestions = !useAdultQuestions;
    });
  }

  Widget enabledGamesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Divider(
            color: Colors.white,
            thickness: 1,
          ),
        ),
        for (GameType type in widget.enabledGames)
          Text(
            "\u2022 " + gameTypeToGameTypeClass(type).translatedTitle,
            style: GoogleFonts.nunito(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
      ],
    );
  }

  Widget buildAdultSelection() {
    if (!hasAdultGames()) return Container();
    return Column(
      children: [
        InkWell(
          onTap:
              adultSwitchEnabled() ? () => toggleAdultQuestions(false) : null,
          child: ListTile(
            title: Text(
              "Include 18+ ?",
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            trailing: CustomSwitch(
              value: useAdultQuestions && adultSwitchEnabled(),
              enabled: widget.enabled,
              onChanged: adultSwitchEnabled() ? toggleAdultQuestions : null,
              activeColor: Colors.black.withOpacity(.4),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Divider(
          thickness: 1,
          color: Colors.white,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 300, maxWidth: 500),
      child: GestureDetector(
        onTap: () => controller.toggle(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: ColorGradient(
            colors: widget.backgroundColors,
            roundness: 30,
            child: ExpandablePanel(
              controller: controller,
              theme: ExpandableThemeData(
                  tapHeaderToExpand: true,
                  tapBodyToExpand: true,
                  tapBodyToCollapse: true,
                  useInkWell: false,
                  iconSize: 0,
                  hasIcon: false),
              header: GestureDetector(
                onTap: () => controller.toggle(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 20, left: 20),
                        child: Icon(
                          widget.icon,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ).tr(),
                            Text(
                              widget.subtitle,
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ).tr(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              collapsed: InkWell(
                onTap: () => controller.toggle(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              expanded: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: enabledGamesSelection(),
                    ),
                    Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                    buildAdultSelection(),
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            RadioProgressIndicator(
                              onChanged: (newVal) {
                                selectedDifficulty = newVal;
                              },
                              enabled: widget.enabled,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: ProgressButton.icon(
                        textStyle: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        progressIndicator: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          color: Colors.white,
                        ),
                        iconedButtons: {
                          ButtonState.idle: IconedButton(
                            text: "startGame".tr(),
                            icon: Icon(Icons.send, color: Colors.white),
                            color: Colors.black.withOpacity(
                              .4,
                            ),
                          ),
                          ButtonState.loading: IconedButton(
                            color: Colors.black.withOpacity(
                              .4,
                            ),
                          ),
                          ButtonState.fail: IconedButton(
                            color: Colors.red,
                            text: "error".tr(),
                            icon: Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                          ),
                          ButtonState.success: IconedButton(
                            color: Colors.green,
                          )
                        },
                        onPressed: widget.enabledGames.isNotEmpty
                            ? () => startGame()
                            : null,
                        state: buttonState,
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.toggle(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

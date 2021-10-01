import 'dart:math';
import 'dart:ui';

import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/utils/drinking.dart';
import 'package:drinkr/widgets/gradient.dart';
import 'package:drinkr/widgets/text_widget.dart';
import 'package:drinkr/utils/types.dart';
import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_dialog/overlay_dialog.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/player.dart';

class BasicGame extends StatefulWidget {
  final String title = "Test Title";

  final Color textColor = Colors.white;
  final Color buttonColor = Color.fromRGBO(0, 0, 0, .4);
  final Color backgroundColor1 = Colors.blue;
  final Color backgroundColor2 = Colors.orange;

  final int drinkingDisplay = 2;

  final GameType type = GameType.undefined;

  final DifficultyType difficulty;

  final bool showSolutionButton = false;

  final String mainTitle = "Error";
  final String solutionText = "Error";

  final List drinking = [];
  final String text;

  final Player selectedPlayer;

  @mustCallSuper
  BasicGame(this.selectedPlayer, this.difficulty, this.text) {
    List<dynamic> resp = Drinking.generateRandomAmount(difficulty);
    drinking
      ..add(resp[0])
      ..add(resp[1]);
  }

  @override
  State<StatefulWidget> createState() => BasicGameState();
}

class BasicGameState extends State<BasicGame>
    with SingleTickerProviderStateMixin {
  bool showSolution = false;

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  String generateMessage() {
    switch (widget.type) {
      case GameType.neverHaveIEver:
        {
          return "neverHaveIEverExplanation".tr();
        }
      case GameType.guess:
        {
          return "guessingExplanation".tr();
        }
      case GameType.guessTheSong:
        {
          return "guessTheSongExplanation".tr();
        }
      case GameType.opinion:
        {
          return "wouldYouRatherExplanation".tr();
        }
      case GameType.quiz:
        {
          return "bigBrainQuizExplanation".tr();
        }
      case GameType.truth:
        {
          return "truthOrDareExplanation".tr();
        }
      case GameType.whoWouldRather:
        {
          return "whoWouldRatherExplanation".tr();
        }
      default:
        return "";
    }
  }

  void displayExitDialog(BuildContext context) {
    DialogHelper().show(
      context,
      DialogWidget.custom(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            backgroundColor: Color.fromRGBO(
                (widget.backgroundColor1.red + widget.backgroundColor2.red) ~/
                    2,
                (widget.backgroundColor1.green +
                        widget.backgroundColor2.green) ~/
                    2,
                (widget.backgroundColor1.blue + widget.backgroundColor2.blue) ~/
                    2,
                1),
            title: Text(
              "exitTitle",
              style: GoogleFonts.nunito(
                textStyle: TextStyle(color: widget.textColor),
                fontWeight: FontWeight.w800,
                fontSize: 30,
              ),
            ).tr(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Text(
              "exitDescription",
              style: GoogleFonts.nunito(
                textStyle: TextStyle(color: widget.textColor),
                fontSize: 25,
              ),
            ).tr(),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                child: Text(
                  "exit",
                  style:
                      GoogleFonts.nunito(color: widget.textColor, fontSize: 20),
                ).tr(),
                onPressed: () {
                  DialogHelper().hide(context);
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text("goOn".tr(),
                    style: GoogleFonts.nunito(
                        color: widget.textColor, fontSize: 20)),
                onPressed: () {
                  DialogHelper().hide(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void displayExitDialog2(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AlertDialog(
            backgroundColor: Color.fromARGB(
              (widget.backgroundColor1.alpha + widget.backgroundColor2.alpha) ~/
                  2,
              (widget.backgroundColor1.red + widget.backgroundColor2.red) ~/ 2,
              (widget.backgroundColor1.green + widget.backgroundColor2.green) ~/
                  2,
              (widget.backgroundColor1.blue + widget.backgroundColor2.blue) ~/
                  2,
            ),
            title: Text(
              "exitTitle",
              style: GoogleFonts.nunito(
                textStyle: TextStyle(color: widget.textColor),
                fontWeight: FontWeight.w800,
                fontSize: 30,
              ),
            ).tr(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: Text(
              "exitDescription",
              style: GoogleFonts.nunito(
                textStyle: TextStyle(color: widget.textColor),
                fontSize: 25,
              ),
            ).tr(),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                child: Text(
                  "exit",
                  style:
                      GoogleFonts.nunito(color: widget.textColor, fontSize: 20),
                ).tr(),
                onPressed: () {
                  Navigator.of(context).pop(true);
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text("goOn".tr(),
                    style: GoogleFonts.nunito(
                        color: widget.textColor, fontSize: 20)),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> displayExitDialogWrapper(BuildContext context) {
    displayExitDialog(context);
    return Future.value(false);
  }

  String buildTitle() {
    return widget.title;
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      leading: IconButton(
        onPressed: () {
          displayExitDialog(context);
        },
        icon: Icon(Icons.clear),
      ),

      /// A very bad fix for an error, which is caused by navigation buttons
      /// still "taking up space" even if they are not visible to the end user,
      /// two different approaches are used to display the text at least approx.
      /// in the centre of the screen. Definitely FIXME
      title: max(MediaQuery.of(context).viewPadding.right,
                  MediaQuery.of(context).viewPadding.left) ==
              0.0
          ? Text(
              buildTitle(),
              style: GoogleFonts.nunito(
                  fontSize: 28,
                  color: widget.textColor,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ).tr()
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                buildTitle(),
                style: GoogleFonts.nunito(
                    color: widget.textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w600),
              ).tr(),
            ]),
      centerTitle: true,
      flexibleSpace: ColorGradient(
        colors: [
          widget.backgroundColor1,
          widget.backgroundColor2,
        ],
        direction: GradientDirection.horizontal,
      ),
    );
  }

  Widget buildTop() {
    return widget.showSolutionButton
        ? buildWithSolution()
        : buildWithoutSolution();
  }

  Widget buildWithSolution() {
    return Column(
      children: <Widget>[
        Expanded(flex: 3, child: buildWithoutSolution()),
        Expanded(
          flex: 1,
          child: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularRevealAnimation(
                    animation: animation,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          // fit: BoxFit.fitHeight,
                          child: Text(
                            widget.solutionText,
                            style: GoogleFonts.nunito(
                                color: widget.textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                  showSolution
                      ? Container()
                      : ShowUpAnimation(
                          child: MaterialButton(
                            elevation: 0,
                            onPressed: () {
                              setState(() {
                                showSolution = true;
                                animationController.forward();
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            color: widget.buttonColor,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  "gameShowSolution",
                                  style: GoogleFonts.nunito(
                                      color: widget.textColor,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600),
                                ).tr(),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildWithoutSolution() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        child: Center(
            child: TextWidget(
          widget.mainTitle,
          textColor: widget.textColor,
        )),
      ),
    );
  }

  Widget buildBottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        widget.drinkingDisplay > 0
            ? Expanded(
                // Middle part, which shows punishment
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 5, 10),
                  child: MaterialButton(
                    elevation: 0,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: AlertDialog(
                              title: Text(
                                "explanation",
                                style: GoogleFonts.nunito(
                                    color: widget.textColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700),
                              ).tr(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              backgroundColor: Color.fromARGB(
                                (widget.backgroundColor1.alpha +
                                        widget.backgroundColor2.alpha) ~/
                                    2,
                                (widget.backgroundColor1.red +
                                        widget.backgroundColor2.red) ~/
                                    2,
                                (widget.backgroundColor1.green +
                                        widget.backgroundColor2.green) ~/
                                    2,
                                (widget.backgroundColor1.blue +
                                        widget.backgroundColor2.blue) ~/
                                    2,
                              ),
                              content: Text(
                                generateMessage(),
                                style: GoogleFonts.nunito(
                                  color: widget.textColor,
                                  fontSize: 25,
                                  // fontWeight: FontWeight.w700,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(
                                    "close",
                                    style: GoogleFonts.nunito(
                                        color: widget.textColor, fontSize: 20),
                                  ).tr(),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: widget.buttonColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DrinkingDisplay(widget.drinking[0],
                          widget.drinking[1], widget.textColor),
                    ),
                  ),
                ),
              )
            : Expanded(
                flex: 1,
                child: Container(),
              ),
        Expanded(
          flex: 2,
          child: Container(),
        ),
        Expanded(
          // Right part, next button
          flex: 1,
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
            child: SizedBox.expand(
              child: MaterialButton(
                onPressed: () => Navigator.of(context).pop(false),
                color: widget.buttonColor,
                elevation: 0,
                //minWidth: 120,
                height: 5000,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Text(
                    "next",
                    style: GoogleFonts.nunito(
                        color: widget.textColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ).tr(),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => displayExitDialogWrapper(context),
      child: Scaffold(
          appBar: buildAppBar(),
          // extendBodyBehindAppBar: true,
          // extendBody: true,
          drawerScrimColor: Colors.green,
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.green,
          body: ColorGradient(
            colors: [
              widget.backgroundColor1,
              widget.backgroundColor2,
            ],
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: buildTop(),
                  ),
                  Container(
                    height: 80,
                    child: buildBottom(),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

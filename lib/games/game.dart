import 'dart:math';

import 'package:Drinkr/utils/drinking.dart';
import 'package:Drinkr/widgets/text_widget.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/player.dart';

class BasicGame extends StatefulWidget {
  final String title = "Test Title";

  final Color primaryColor = Colors.blue;
  final Color secondaryColor = Colors.yellow;
  final int drinkingDisplay = 2;

  final GameType type = GameType.UNDEFINED;

  final List<Player> players;
  final int difficulty;

  final bool showSolutionButton = false;

  final String mainTitle = "Error";
  final String solutionText = "Error";

  final List drinking = List();
  final String text;

  final List<Player> selectedPlayer = List<Player>();

  @mustCallSuper
  BasicGame(this.players, this.difficulty, this.text) {
    List<dynamic> resp = Drinking.generateRandomAmount(difficulty);
    this.drinking..add(resp[0])..add(resp[1]);
    this.selectedPlayer.add(players[Random.secure().nextInt(players.length)]);
  }

  @override
  State<StatefulWidget> createState() => BasicGameState();
}

class BasicGameState extends State<BasicGame>
    with SingleTickerProviderStateMixin {
  bool showSolution = false;

  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeIn);
  }

  String generateMessage() {
    switch (widget.type) {
      case GameType.NEVER_HAVE_I_EVER:
        {
          return "neverHaveIEverExplanation".tr();
        }
      case GameType.GUESS:
        {
          return "guessingExplanation".tr();
        }
      case GameType.GUESS_THE_SONG:
        {
          return "guessTheSongExplanation".tr();
        }
      case GameType.OPINION:
        {
          return "wouldYouRatherExplanation".tr();
        }
      case GameType.QUIZ:
        {
          return "bigBrainQuizExplanation".tr();
        }
      case GameType.TRUTH:
        {
          return "truthOrDareExplanation".tr();
        }
      case GameType.WHO_WOULD_RATHER:
        {
          return "whoWouldRatherExplanation".tr();
        }
      default:
        return "";
    }
  }

  void displayExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.primaryColor,
          title: Text("exitTitle",
              style: GoogleFonts.caveatBrush(
                textStyle: TextStyle(color: Colors.black),
                fontWeight: FontWeight.w800,
                fontSize: 30,
              )).tr(),
          content: Text(
            "exitDescription",
            style: GoogleFonts.caveatBrush(
              textStyle: TextStyle(color: Colors.black),
              fontSize: 25,
            ),
          ).tr(),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(
                "exit",
                style:
                    GoogleFonts.caveatBrush(color: Colors.black, fontSize: 20),
              ).tr(),
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(true);
              },
            ),
            FlatButton(
              child: Text("goOn".tr(),
                  style: GoogleFonts.caveatBrush(
                      color: Colors.black, fontSize: 20)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> displayExitDialogWrapper(BuildContext context) {
    displayExitDialog(context);
    return Future.value(true);
  }

  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
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
              widget.title,
              style: GoogleFonts.caveatBrush(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ).tr()
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                widget.title,
                style: GoogleFonts.caveatBrush(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.w600),
              ).tr(),
            ]),
      centerTitle: true,
      backgroundColor: widget.primaryColor,
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
                            style: GoogleFonts.caveatBrush(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                  this.showSolution
                      ? Container()
                      : ShowUpAnimation(
                          child: MaterialButton(
                            onPressed: () {
                              setState(() {
                                this.showSolution = true;
                                animationController.forward();
                              });
                            },
                            color: widget.secondaryColor,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                "gameShowSolution",
                                style: GoogleFonts.caveatBrush(
                                    color: Colors.black,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w600),
                              ).tr(),
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
        child: Center(child: TextWidget(widget.mainTitle)),
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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "explanation",
                              style: GoogleFonts.caveatBrush(
                                  color: Colors.black,
                                  fontSize: 45,
                                  fontWeight: FontWeight.w700),
                            ).tr(),
                            backgroundColor: widget.secondaryColor,
                            content: Text(
                              generateMessage(),
                              style: GoogleFonts.caveatBrush(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700),
                            ),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              FlatButton(
                                child: Text(
                                  "close",
                                  style: GoogleFonts.caveatBrush(
                                      color: Colors.black, fontSize: 20),
                                ).tr(),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    color: widget.secondaryColor,
                    child: DrinkingDisplay(
                        widget.drinking[0], widget.drinking[1], Colors.black),
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
            child: MaterialButton(
              onPressed: () => Navigator.of(context).pop(false),
              color: widget.secondaryColor,
              //minWidth: 120,
              height: 5000,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  "next",
                  style: GoogleFonts.caveatBrush(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.w600),
                ).tr(),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    /*SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);*/
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () => displayExitDialogWrapper(context),
      child: Scaffold(
        appBar: buildAppBar(),
        body: Container(
          color: widget.primaryColor,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: buildTop(),
              ),
              Expanded(
                flex: 1,
                child: buildBottom(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

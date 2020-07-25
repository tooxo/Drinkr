import 'dart:async';
import 'dart:convert';

import 'package:BoozeBuddy/games/game.dart';
import 'package:BoozeBuddy/utils/networking.dart';
import 'package:BoozeBuddy/utils/types.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/player.dart';

class GuessTheSong extends BasicGame {
  final bool showSolutionButton = true;
  final Color primaryColor = Color.fromRGBO(46, 125, 50, 1);
  final Color secondaryColor = Color.fromRGBO(96, 173, 94, 1);

  final GameType type = GameType.GUESS_THE_SONG;

  final String title = "guessTheSong";
  final int drinkingDisplay = 1;

  GuessTheSong(List<Player> players, int difficulty, String text)
      : super(players, difficulty, text);

  @override
  State<StatefulWidget> createState() => new GuessTheSongState();

  @override
  String get mainTitle => JsonDecoder().convert(text)[1];

  @override
  String get solutionText => JsonDecoder().convert(text)[0];
}

class GuessTheSongState extends BasicGameState with WidgetsBindingObserver {
  bool showSolution = false;
  double state = 0;
  AudioPlayer audioPlayer;

  // ignore: cancel_subscriptions
  StreamSubscription<Duration> durationSubscription;

  // ignore: cancel_subscriptions
  StreamSubscription<AudioPlayerState> stateSubscription;

  @override
  void dispose() {
    this.durationSubscription?.cancel();
    this.stateSubscription?.cancel();
    this.audioPlayer.stop();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void buttonClick() async {
    if (state == 0 || state == 1) {
      if (await checkConnection()) {
        audioPlayer.play(widget.mainTitle);
      } else {
        Fluttertoast.showToast(
            msg: "noConnection".tr(), toastLength: Toast.LENGTH_SHORT);
      }
    }
    if (state < 1 && state > 0) {
      setState(() {
        if (audioPlayer.state == AudioPlayerState.PAUSED) {
          // audioPlayer.play(widget.mainTitle);
          audioPlayer.resume();
          audioPlayer.state = AudioPlayerState.PLAYING;
        } else {
          audioPlayer.pause();
          audioPlayer.state = AudioPlayerState.PAUSED;
        }
      });
    }
  }

  int songDuration;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    audioPlayer = new AudioPlayer();
    this.durationSubscription =
        audioPlayer.onAudioPositionChanged.listen((pos) async {
      if (songDuration == null) {
        songDuration = await audioPlayer.getDuration();
      }
      this.state = pos.inMilliseconds / songDuration;
      if (mounted) {
        setState(() {});
      }
    });
    this.stateSubscription = audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.COMPLETED) {
        setState(() {
          this.state = 1;
        });
      }
    }, onError: (msg) {
      Fluttertoast.showToast(
          msg: "An unexpected Error occurred.",
          toastLength: Toast.LENGTH_SHORT);
      this.state = 1;
      setState(() {});
    });
  }

  @override
  Widget buildWithoutSolution() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: ShowUpAnimation(
          child: Transform.scale(
            scale: 2,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  value: state,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                  backgroundColor: Colors.black.withAlpha(80),
                ),
                IconButton(
                  onPressed: buttonClick,
                  icon: Icon(
                    state == 1
                        ? Icons.replay
                        : state == 0
                            ? Icons.play_arrow
                            : this.audioPlayer.state == AudioPlayerState.PAUSED
                                ? Icons.play_arrow
                                : Icons.pause,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

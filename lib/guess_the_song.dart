import 'dart:async';
import 'dart:convert';

import 'package:SaufApp/game.dart';
import 'package:SaufApp/types.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:show_up_animation/show_up_animation.dart';

import 'player.dart';

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
    if (this.durationSubscription != null) {
      this.durationSubscription.cancel();
    }

    if (this.stateSubscription != null) {
      this.stateSubscription.cancel();
    }

    this.audioPlayer.stop();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      setState(() {
        this.audioPlayer.pause();
      });
    }
  }

  void buttonClick() {
    if (state == 0 || state == 1) {
      audioPlayer.play(widget.mainTitle);
    }
    if (state < 1 && state > 0) {
      setState(() {
        if (audioPlayer.state == AudioPlayerState.PAUSED) {
          // audioPlayer.play(widget.mainTitle);
          audioPlayer.resume();
        } else {
          audioPlayer.pause();
        }
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    audioPlayer = new AudioPlayer();
    this.durationSubscription =
        audioPlayer.onAudioPositionChanged.listen((pos) async {
      this.state = pos.inMilliseconds / await audioPlayer.getDuration();
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
      // TODO: Show Error Message!
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

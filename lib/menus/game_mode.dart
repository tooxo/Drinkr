import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/widgets/custom_game_select_tile.dart';
import 'package:Drinkr/widgets/game_select_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/types.dart';

class GameMode extends StatefulWidget {
  final List<Player> players;

  static const IconData icon_custom =
      IconData(0xe800, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_guessthesong =
      IconData(0xe801, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_quiz =
      IconData(0xe802, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_dirty =
      IconData(0xe803, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_party =
      IconData(0xe804, fontFamily: 'GameModeSelectionIcons', fontPackage: null);

  const GameMode(this.players, {Key? key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

enum CurrentGameState { STOPPED, LOADING, IN_GAME }

class GameState extends State<GameMode> {
  CurrentGameState gameState = CurrentGameState.STOPPED;

  void onStateChange(CurrentGameState newState) {
    setState(() {
      gameState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return gameState == CurrentGameState.IN_GAME
        ? Container()
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Color.fromRGBO(21, 21, 21, 1),
              title: Text(
                "Wähle deinen Spielmodus",
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ).tr(),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            backgroundColor: Color.fromRGBO(21, 21, 21, 1),
            body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Divider(),
                  GameSelectTile(
                    enabled: gameState == CurrentGameState.STOPPED,
                    backgroundColors: [
                      Color.fromRGBO(255, 27, 24, 1),
                      Color.fromRGBO(241, 61, 180, 1),
                    ],
                    parentContext: context,
                    onGameStateChange: onStateChange,
                    title: "Party",
                    subtitle: "Spaß für die ganze Familie",
                    icon: GameMode.icon_party,
                    players: widget.players,
                    enabledGames: [
                      GameType.DARE,
                      GameType.TRUTH,
                      GameType.CHALLENGES,
                      GameType.NEVER_HAVE_I_EVER,
                      GameType.OPINION,
                      GameType.WHO_WOULD_RATHER
                    ],
                  ),
                  Divider(),
                  GameSelectTile(
                    enabled: gameState == CurrentGameState.STOPPED,
                    backgroundColors: [
                      Color.fromRGBO(79, 44, 208, 1),
                      Color.fromRGBO(7, 149, 199, 1),
                    ],
                    parentContext: context,
                    onGameStateChange: onStateChange,
                    title: "Quiz",
                    subtitle: "Teste dein Wissen!",
                    icon: GameMode.icon_quiz,
                    players: widget.players,
                    enabledGames: [
                      GameType.QUIZ,
                      GameType.GUESS,
                    ],
                  ),
                  Divider(),
                  GameSelectTile(
                    enabled: gameState == CurrentGameState.STOPPED,
                    backgroundColors: [
                      Color.fromRGBO(25, 96, 2, 1),
                      Color.fromRGBO(95, 154, 0, 1),
                    ],
                    parentContext: context,
                    onGameStateChange: onStateChange,
                    title: "Lieder raten",
                    subtitle: "Errate den Song als erstes!",
                    icon: GameMode.icon_guessthesong,
                    players: widget.players,
                    enabledGames: [
                      GameType.GUESS_THE_SONG,
                    ],
                  ),
                  Divider(),
                  CustomGameSelectTile(
                    title: "custom",
                    subtitle: "Wähle zwischen allen Spielen!",
                    icon: GameMode.icon_custom,
                    players: widget.players,
                    enabledGames: [],
                    backgroundColors: [
                      Color.fromRGBO(131, 58, 180, 1),
                      Color.fromRGBO(253, 29, 29, 1),
                      Color.fromRGBO(253, 187, 45, 1),
                    ],
                    parentContext: context,
                    onGameStateChange: onStateChange,
                    enabled: gameState == CurrentGameState.STOPPED,
                  ),
                  Divider(),
                ],
              ),
            ),
          );
  }
}

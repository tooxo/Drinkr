import 'package:Drinkr/utils/player.dart';
import 'package:Drinkr/utils/types.dart';
import 'package:Drinkr/widgets/BasicTile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/types.dart';

class GameMode extends StatefulWidget {
  final List<Player> players;

  static const IconData icon_custom = IconData(0xe800, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_guessthesong = IconData(0xe801, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_quiz = IconData(0xe802, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_dirty = IconData(0xe803, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_party = IconData(0xe804, fontFamily: 'GameModeSelectionIcons', fontPackage: null);

  const GameMode(this.players, {Key? key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

class GameState extends State<GameMode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        title: Text(
          "Wähle deinen Spielmodus",
          style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ).tr(),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Divider(),
            BasicTile(
              mainColor: Color.fromRGBO(255, 27, 24, 1),
              secondaryColor: Color.fromRGBO(241, 61, 180, 1),
              title: "Party",
              description: "Spaß für die ganze Familie",
              icon: GameMode.icon_party,
              games: "\u2022 Wahrheit oder Pflicht\n"
                  "\u2022 Wer würde eher\n"
                  "\u2022 Entweder ... oder...?\n"
                  "\u2022 Challenges\n"
                  "\u2022 Ich hab noch nie...?",
              enabledGames: [
                GameType.DARE,
                GameType.TRUTH,
                GameType.CHALLENGES,
                GameType.NEVER_HAVE_I_EVER,
                GameType.OPINION,
              ],
              players: widget.players,
            ),
            BasicTile(
              mainColor: Color.fromRGBO(79, 44, 208, 1),
              secondaryColor: Color.fromRGBO(7, 149, 199, 1),
              title: "Quiz",
              description: "Teste dein Wissen!",
              icon: GameMode.icon_quiz,
              games: "\u2022 Big brain Quiz\n" "\u2022 Schätzfragen",
              enabledGames: [],
              players: widget.players,
            ),
            BasicTile(
              mainColor: Color.fromRGBO(118, 13, 123, 1),
              secondaryColor: Color.fromRGBO(220, 15, 17, 1),
              title: "Dirty",
              description: "Intime Fragen",
              icon: GameMode.icon_dirty,
              games: "\u2022 Wahrheit oder Pflicht(+18)\n"
                  "\u2022 Wer würde eher(+18)",
              players: widget.players,
              enabledGames: [],
            ),
            BasicTile(
              mainColor: Color.fromRGBO(25, 96, 2, 1),
              secondaryColor: Color.fromRGBO(95, 154, 0, 1),
              title: "Lieder raten",
              description: "Errate das Lied als erstes!",
              icon: GameMode.icon_guessthesong,
              games: "\u2022 Rate den Song",
              players: widget.players,
              enabledGames: [GameType.GUESS_THE_SONG],
            ),
            BasicTile(
              mainColor: Color.fromRGBO(255, 27, 24, 1).withOpacity(0.5),
              secondaryColor: Color.fromRGBO(241, 61, 180, 1).withOpacity(0.5),
              title: "Custom",
              description: "Wähle zwischen allen Spielen!",
              icon: GameMode.icon_custom,
              textColor: Colors.white.withOpacity(0.5),
              topIcon: Icons.lock_outline,
              games: "Kauf pls I need money",
              players: widget.players,
              enabledGames: [],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}

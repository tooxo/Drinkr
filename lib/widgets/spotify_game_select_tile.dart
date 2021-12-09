import 'dart:ui';

import 'package:drinkr/menus/game_mode.dart';
import 'package:drinkr/menus/setting.dart';
import 'package:drinkr/utils/player.dart';
import 'package:drinkr/utils/types.dart';
import 'package:drinkr/widgets/purchasable.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_select_tile.dart';
import 'package:flutter/material.dart';

class SpotifyGameSelectTile extends GameSelectTile {
  SpotifyGameSelectTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<GameType> enabledGames,
    required List<Player> players,
    required ValueChanged<CurrentGameState> onGameStateChange,
    required BuildContext parentContext,
    required bool enabled,
    required List<Color> backgroundColors,
  }) : super(
            icon: icon,
            title: title,
            subtitle: subtitle,
            enabledGames: enabledGames,
            players: players,
            onGameStateChange: onGameStateChange,
            parentContext: parentContext,
            enabled: enabled,
            backgroundColors: backgroundColors);

  @override
  _SpotifyGameSelectTileState createState() => _SpotifyGameSelectTileState();
}

class _SpotifyGameSelectTileState extends GameSelectTileState {
  @override
  Widget enabledGamesSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          thickness: 1,
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Purchasable(
            child: ButtonTheme(
              minWidth: double.infinity,
              child: MaterialButton(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => Settings(
                        openSpotify: true,
                      ),
                    ),
                  );
                },
                color: Colors.black.withOpacity(.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Text(
                      "+ " + "addPlaylists".tr(),
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
            showLock: true,
            alignment: Alignment.centerLeft,
          ),
        )
      ],
    );
  }
}

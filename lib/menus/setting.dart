import 'dart:ui';

import 'package:drinkr/menus/licenses.dart';
import 'package:drinkr/utils/ad.dart';
import 'package:drinkr/utils/custom_icons.dart';
import 'package:drinkr/utils/spotify_api.dart';
import 'package:drinkr/utils/spotify_storage.dart';
import 'package:drinkr/widgets/extending_textfield_button.dart';
import 'package:drinkr/widgets/gradient.dart';
import 'package:drinkr/widgets/icon_list_tile.dart';
import 'package:drinkr/widgets/spotify_tile.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  static const String SETTING_INCLUSION_OF_QUESTIONS =
      "SETTING_INCLUSION_OF_QUESTIONS";

  static const int ONLY_INCLUDED = 0;
  static const int BOTH = 1;
  static const int ONLY_CUSTOM = 2;

  bool spotifyEdit = false;
  ExpandableController spotifyController = ExpandableController();

  void onPlaylistChange(Playlist playlist) async {
    await SpotifyStorage.playlists_box.put(playlist.id, playlist);
    setState(() {});
  }

  void onPlaylistDelete(Playlist playlist) async {
    await SpotifyStorage.playlists_box.delete(playlist.id);
    setState(() {});
  }

  ButtonState adButtonState = ButtonState.idle;

  void onAdButtonStateChange(ButtonState newState) {
    setState(() {
      adButtonState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        title: Text(
          "settings",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ).tr(),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ColorGradient(
                colors: [
                  Color.fromRGBO(36, 140, 0, 1),
                  Color.fromRGBO(36, 140, 0, 1),
                ],
                roundness: 15,
                child: ExpandablePanel(
                  controller: spotifyController,
                  theme: ExpandableThemeData(
                    hasIcon: false,
                    useInkWell: false,
                  ),
                  header: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16,
                    ),
                    child: IconListTile(
                      iconData: CustomIcons.spotify,
                      title: "Spotify Playlists",
                      subtitle: "Spiele mit eigenen Songs",
                      onTap: () {},
                      iconSize: 55,
                    ),
                  ),
                  collapsed: GestureDetector(
                    onTap: () {
                      spotifyController.toggle();
                    },
                    child: Center(
                      child: Container(
                        child: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  expanded: Column(
                    children: [
                      Divider(
                        color: Colors.white,
                        thickness: 1,
                        height: 1,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 350,
                        ),
                        child: Container(
                          color: Color.fromRGBO(36, 140, 0, 1),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  for (Playlist p in SpotifyStorage
                                      .playlists_box.values
                                      .toList()
                                        ..sort())
                                    SpotifyTile(
                                      p,
                                      onChanged: onPlaylistChange,
                                      onDelete: onPlaylistDelete,
                                      expanded: spotifyEdit,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.white,
                        thickness: 1,
                        height: 1,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ExtendingTextFieldButton(
                              () {
                                setState(() {
                                  spotifyEdit = !spotifyEdit;
                                });
                              },
                              this.spotifyEdit,
                              (Playlist playlist) async {
                                await SpotifyStorage.playlists_box
                                    .put(playlist.id, playlist);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          spotifyController.toggle();
                        },
                        child: Center(
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ColorGradient(
                roundness: 15,
                colors: [
                  Color.fromRGBO(0x2B, 0xA5, 0x00, 1),
                  Color.fromRGBO(0x2B, 0xA5, 0x00, 1),
                ],
                child: ExpandablePanel(
                  theme: ExpandableThemeData(
                    hasIcon: false,
                  ),
                  header: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16,
                    ),
                    child: IconListTile(
                      title: "Werbung deaktivieren",
                      subtitle:
                          "schaue ein kurzes Video und deaktiviere die Werbung für eine Stunde!",
                      iconData: Icons.circle,
                      onTap: () {},
                    ),
                  ),
                  collapsed: Center(
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.white,
                    ),
                  ),
                  expanded: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Divider(
                          color: Colors.white,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        child: ProgressButton.icon(
                          onPressed: () {
                            showInterstitialAd(context, onAdButtonStateChange);
                          },
                          state: adButtonState,
                          textStyle: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          iconedButtons: {
                            ButtonState.idle: IconedButton(
                              color: Colors.black.withOpacity(.4),
                              text: "startGame".tr(),
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
                            ButtonState.fail: IconedButton(
                              color: Colors.redAccent,
                            ),
                            ButtonState.loading: IconedButton(
                              color: Colors.black.withOpacity(.4),
                            ),
                            ButtonState.success: IconedButton(
                              color: Colors.green,
                            )
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          "30-sekündiges Video schauen,\num Werbung für 1h zu deaktivieren",
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_up_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "App Bewerten",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sprache",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Fragen/Vorschläge",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Licenses()));
                  },
                  child: Container(
                    color: Color.fromRGBO(21, 21, 21, 1),
                    child: Container(
                      height: 80,
                      width: 350.0,
                      decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.8),
                              blurRadius: 8,
                              offset:
                                  Offset(2, 10), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Über uns / Lizensen",
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800),
                            ).tr(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

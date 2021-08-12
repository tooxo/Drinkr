import 'dart:ui';

import 'package:Drinkr/menus/licenses.dart';
import 'package:Drinkr/utils/spotify_api.dart';
import 'package:Drinkr/utils/spotify_storage.dart';
import 'package:Drinkr/widgets/extending_textfield_button.dart';
import 'package:Drinkr/widgets/gradient.dart';
import 'package:Drinkr/widgets/spotify_tile.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
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

  late SharedPreferences sp;

  int sliderState = 1;
  bool customQuestionsAvailable = false;

  bool spotifyEdit = false;
  ExpandableController spotifyController = ExpandableController();

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      sp = value;
      sliderState = sp.getInt(SETTING_INCLUSION_OF_QUESTIONS) ?? 1;
    });
    spotifyController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void onPlaylistChange(Playlist playlist) async {
    await SpotifyStorage.playlists_box.put(playlist.id, playlist);
    setState(() {});
  }

  void onPlaylistDelete(Playlist playlist) async {
    await SpotifyStorage.playlists_box.delete(playlist.id);
    setState(() {});
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
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ).tr(),
        iconTheme: IconThemeData(color: Colors.white),
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
                  theme: ExpandableThemeData(hasIcon: false, useInkWell: false),
                  header: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 20),
                          child: Icon(
                            Icons.circle,
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
                                "Spotify Playlists",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ).tr(),
                              Text(
                                "Spiele mit eigenen Songs!",
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
                        color: Colors.black,
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
                        color: Colors.black,
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
                              "Werbung ausschalten",
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

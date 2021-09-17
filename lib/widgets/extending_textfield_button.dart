import 'dart:math';

import 'package:drinkr/utils/custom_icons.dart';
import 'package:drinkr/utils/spotify_api.dart';
import 'package:drinkr/utils/spotify_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedantic/pedantic.dart';
import 'package:show_up_animation/show_up_animation.dart';

class ExtendingTextFieldButton extends StatefulWidget {
  final Function() toggleExtend;
  final bool extended;

  final Function(Playlist) onNewPlaylist;

  const ExtendingTextFieldButton(
      this.toggleExtend, this.extended, this.onNewPlaylist);

  @override
  _ExtendingTextFieldButtonState createState() =>
      _ExtendingTextFieldButtonState();
}

enum CurrentState {
  IDLE,
  CHECKING,
  SUCCESS,
  FAILURE,
}

class _ExtendingTextFieldButtonState extends State<ExtendingTextFieldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late TextEditingController textEditingController;

  String? errorText;

  CurrentState currentState = CurrentState.IDLE;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(
        () {
          if (controller.value == 0.0) {
            textEditingController.clear();
          }
        },
      );
    textEditingController = TextEditingController()
      ..addListener(
        () {
          if (textEditingController.text.isEmpty) {
            errorText = null;
          }
        },
      );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  Future<bool> check() async {
    setState(() {
      currentState = CurrentState.CHECKING;
    });
    String? id = Spotify.getIdFromUrl(textEditingController.text);

    if (id == null) {
      currentState = CurrentState.FAILURE;
      errorText = "not a spotify playlist url";
      return false;
    }

    if (SpotifyStorage.playlists_box.keys.contains(id)) {
      currentState = CurrentState.FAILURE;
      errorText = "playlist duplicate";
      return false;
    }

    bool playlistExists =
        await Spotify.playlistExists("https://open.spotify.com/playlist/$id");

    if (!playlistExists) {
      currentState = CurrentState.FAILURE;
      errorText = "playlist not found";
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0, left: 8),
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: widget.extended
                        ? Colors.white.withOpacity(.15)
                        : Colors.white.withOpacity(.3),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.toggleExtend,
                    icon: Icon(
                      CustomIcons.trash,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            currentState == CurrentState.SUCCESS
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: ShowUpAnimation(
                        delayStart: Duration.zero,
                        animationDuration: Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                "SUCCESS!",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    flex: 1,
                  )
                : Container(),
            currentState == CurrentState.FAILURE
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "FAILURE!",
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    flex: 1,
                  )
                : Container(),
            AnimatedBuilder(
              builder: (BuildContext context, Widget? _) {
                return Container(
                  width: 48 +
                      (constraints.maxWidth - 48 - 48 - 8) * controller.value,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: (constraints.maxWidth - 48 - 48 - 8) *
                            controller.value,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            left: 24.0,
                            bottom: 8,
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Spotify Url",
                              hintStyle: GoogleFonts.nunito(
                                  color: Colors.white.withOpacity(.6)),
                              errorText: errorText,
                              contentPadding:
                                  EdgeInsets.only(top: 4, bottom: 0),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              suffixIcon: !controller.isCompleted
                                  ? Container()
                                  : IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          textEditingController.clear();
                                        });
                                      },
                                    ),
                              isDense: true,
                              errorMaxLines: 1,
                              errorStyle: TextStyle(fontSize: 0, height: 0),
                            ),
                            controller: textEditingController,
                            style: GoogleFonts.nunito(
                                fontSize: 18, color: Colors.white),
                            onChanged: (n) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      currentState == CurrentState.CHECKING
                          ? Padding(
                              padding: const EdgeInsets.only(left: 9.0),
                              child: Container(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                                width: 30,
                                height: 30,
                              ),
                            )
                          : Transform.rotate(
                              angle: controller.value / 4 * pi - 0.785398,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  textEditingController.value.text.trim() ==
                                              "" ||
                                          controller.status ==
                                              AnimationStatus.reverse
                                      ? Icons.close
                                      : Icons.check,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  if (textEditingController.text.isNotEmpty) {
                                    if (await check()) {
                                      Playlist? p = await Spotify()
                                          .getPlaylistWithoutSongs(
                                        Spotify.getIdFromUrl(
                                            textEditingController.text)!,
                                        included: false,
                                      );
                                      if (p != null) {
                                        widget.onNewPlaylist(p);
                                      }
                                      await controller.reverse();
                                      setState(() {
                                        currentState = CurrentState.SUCCESS;
                                      });
                                    } else {
                                      await controller.reverse();
                                      setState(() {});
                                    }
                                  } else {
                                    if (controller.isCompleted) {
                                      await controller.reverse();
                                      FocusScope.of(context).unfocus();
                                      setState(() {});
                                    } else {
                                      setState(() {
                                        currentState = CurrentState.IDLE;
                                      });
                                      unawaited(controller.forward());
                                    }
                                  }
                                },
                              ),
                            ),
                    ],
                  ),
                );
              },
              animation: controller,
            )
          ],
        );
      }),
    );
  }
}

import 'package:drinkr/utils/custom_icons.dart';
import 'package:drinkr/utils/spotify_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyTile extends StatelessWidget {
  final bool expanded;

  // SlidableController controller = SlidableController();

  final Playlist playlist;
  final ValueChanged<Playlist> onChanged;

  final Function(Playlist) onDelete;

  SpotifyTile(
    this.playlist, {
    required this.onChanged,
    required this.expanded,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          width: constraints.maxWidth,
          height: 78,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedPositioned(
                left: expanded ? 48 + 16 : 8,
                width: constraints.maxWidth - 8,
                // height: 70,
                duration: Duration(milliseconds: 200),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: playlist.enabled
                              ? Colors.black.withOpacity(.7)
                              : Colors.black.withOpacity(.3),
                        ),
                        child: ListTile(
                          // tileColor: Colors.black,
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          title: Text(
                            playlist.name,
                            style: GoogleFonts.nunito(
                              color: playlist.enabled
                                  ? Colors.white
                                  : Colors.white.withOpacity(.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(
                                left: 12.0, top: 4, bottom: 4),
                            child: Opacity(
                              opacity: playlist.enabled ? 1 : .6,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: CachedNetworkImage(
                                  width: 48,
                                  height: 48,
                                  imageUrl: playlist.imageUrl,
                                ),
                              ),
                            ),
                          ),
                          subtitle: Text(
                            playlist.creatorName,
                            style: GoogleFonts.nunito(
                              color: playlist.enabled
                                  ? Colors.white
                                  : Colors.white.withOpacity(.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.open_in_new,
                              color: playlist.enabled
                                  ? Colors.white
                                  : Colors.white.withOpacity(.6),
                            ),
                            onPressed: () async {
                              if (await canLaunch(playlist.url)) {
                                await launch(playlist.url);
                              } else {
                                print("cant launch");
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Transform.scale(
                        scale: 1.6,
                        child: Checkbox(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side: BorderSide(
                            color: Colors.black.withOpacity(.7),
                            width: 2,
                          ),
                          checkColor: Colors.white,
                          activeColor: Colors.black.withOpacity(.7),
                          fillColor: MaterialStateProperty.all(
                            Colors.black.withOpacity(.7),
                          ),
                          overlayColor:
                              MaterialStateProperty.all(Colors.transparent),
                          value: playlist.enabled,
                          onChanged: (bool? value) {
                            playlist.enabled = value!;
                            onChanged(playlist);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                left: expanded ? 0.0 : -48 - 16,
                duration: Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 48,
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 8, bottom: 8, right: 8),
                      child: Container(
                        decoration: BoxDecoration(
                            color: playlist.included
                                ? Colors.white.withOpacity(.15)
                                : Colors.white.withOpacity(.3),
                            borderRadius: BorderRadius.circular(5)),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: playlist.included
                              ? null
                              : () => onDelete(playlist),
                          icon: Icon(
                            CustomIcons.trash,
                            color: playlist.included
                                ? Colors.white.withOpacity(.3)
                                : Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

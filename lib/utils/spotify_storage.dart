import 'package:drinkr/utils/file.dart';
import 'package:drinkr/utils/networking.dart';
import 'package:drinkr/utils/spotify_api.dart';
import 'package:drinkr/utils/types.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class SpotifyStorage {
  static var songs_box = Hive.box<Song>("spotify_songs");
  static var playlists_box = Hive.box<Playlist>("spotify_playlists");

  static Future<Song?> getFromSpotifyCache(String songId) async {
    return songs_box.get(songId);
  }

  static Future<void> initializePreshippedPlaylists(
      BuildContext context) async {
    List<String> playlistIds =
        (await getIncludedFiles(GameType.GUESS_THE_SONG, context, false))
            .map(Spotify.getIdFromUrl)
            .map((e) => e!)
            .toList();

    List<String> missingPlaylistIds = playlistIds
        .where((element) => !playlists_box.keys.contains(element))
        .toList();

    if (await checkConnection()) {
      for (String pid in missingPlaylistIds) {
        Playlist? p = await Spotify().getPlaylistWithoutSongs(pid);
        if (p == null) continue;

        await playlists_box.put(pid, p);
      }
    }
  }

  static Future<void> putBulkInSpotifyCache(Iterable<Song> songs) async {
    for (Song song in songs) {
      Song? old_entry = songs_box.get(song.id);

      // preserve previewUrl if no new one is provided
      if (old_entry != null) {
        if (old_entry.previewUrl != null && song.previewUrl == null) {
          song.previewUrl = old_entry.previewUrl;
        }
      }
      await songs_box.put(song.id, song);
    }
  }

  static Playlist? getPlaylistFromSpotifyCache(String playlistId) {
    return playlists_box.get(playlistId);
  }

  static Future<void> putBulkInSpotifyPlaylistCache(
      Iterable<Playlist> playlists) async {
    for (Playlist playlist in playlists) {
      await playlists_box.put(playlist.id, playlist);
    }
  }
}

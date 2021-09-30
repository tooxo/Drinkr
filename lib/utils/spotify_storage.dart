import 'package:drinkr/utils/file.dart';
import 'package:drinkr/utils/networking.dart';
import 'package:drinkr/utils/spotify_api.dart';
import 'package:drinkr/utils/types.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class SpotifyStorage {
  static var songsBox = Hive.box<Song>("spotify_songs");
  static var playlistsBox = Hive.box<Playlist>("spotify_playlists");

  static Future<Song?> getFromSpotifyCache(String songId) async {
    return songsBox.get(songId);
  }

  static Future<void> initializePreshippedPlaylists(
      BuildContext context) async {
    List<String> playlistIds =
        (await getIncludedFiles(GameType.guessTheSong, context, false))
            .map(Spotify.getIdFromUrl)
            .map((e) => e!)
            .toList();

    List<String> missingPlaylistIds = playlistIds
        .where((element) => !playlistsBox.keys.contains(element))
        .toList();

    if (await checkConnection()) {
      for (String pid in missingPlaylistIds) {
        Playlist? p = await Spotify().getPlaylistWithoutSongs(pid);
        if (p == null) continue;

        await playlistsBox.put(pid, p);
      }
    }
  }

  static Future<void> putBulkInSpotifyCache(Iterable<Song> songs) async {
    for (Song song in songs) {
      Song? oldEntry = songsBox.get(song.id);

      // preserve previewUrl if no new one is provided
      if (oldEntry != null) {
        if (oldEntry.previewUrl != null && song.previewUrl == null) {
          song.previewUrl = oldEntry.previewUrl;
        }
      }
      await songsBox.put(song.id, song);
    }
  }

  static Playlist? getPlaylistFromSpotifyCache(String playlistId) {
    return playlistsBox.get(playlistId);
  }

  static Future<void> putBulkInSpotifyPlaylistCache(
      Iterable<Playlist> playlists) async {
    for (Playlist playlist in playlists) {
      await playlistsBox.put(playlist.id, playlist);
    }
  }
}

import 'package:Drinkr/utils/spotify_api.dart';
import 'package:hive/hive.dart';

class SpotifyStorage {
  static var songs_box = Hive.box<Song>("spotify_songs");
  static var playlists_box = Hive.box<Playlist>("spotify_playlists");

  static Future<Song?> getFromSpotifyCache(String songId) async {
    return songs_box.get(songId);
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

  static Future<Playlist?> getPlaylistFromSpotifyCache(
      String playlistId) async {
    return playlists_box.get(playlistId);
  }

  static Future<void> putBulkInSpotifyPlaylistCache(
      Iterable<Playlist> playlists) async {
    for (Playlist playlist in playlists) {
      await playlists_box.put(playlist.id, playlist);
    }
  }
}

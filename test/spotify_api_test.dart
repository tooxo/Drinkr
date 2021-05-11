import 'package:Drinkr/utils/spotify_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
// ignore: avoid_relative_lib_imports

void main() {
  Hive.init(".");

  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(PlaylistAdapter());

  Hive.openBox<Playlist>("spotify_playlists");
  Hive.openBox<Song>("spotify_songs");

  test("test playlist id extraction by regex usage", () {
    Map<String, String> urlsToTest = {
      "https://open.spotify.com/playlist/37i9dQZF1DWX7rdRjOECPW?si=v8CMn-KRQFCCz0dugDIg4g":
          "37i9dQZF1DWX7rdRjOECPW",
      "https://open.spotify.com/playlist/37i9dQZF1DWUTqhVTO6wIG":
          "37i9dQZF1DWUTqhVTO6wIG",
      "https://open.spotify.com/playlist/37i9dQZF1DWWhBhYl3ZMvY?":
          "37i9dQZF1DWWhBhYl3ZMvY"
    };
    for (String url in urlsToTest.keys) {
      expect(Spotify.getIdFromUrl(url), urlsToTest[url]);
    }
  });
  test("test function to check if a spotify playlist exists", () async {
    Map<String, bool> urlsToTest = {
      "https://open.spotify.com/playlist/37i9dQZF1DWX7rdRjOECPW?si=0AsXmQydR521jxbOFj58gQ":
          true,
      "https://open.spotify.com/playlist/37i9dQZF1DWX7rdRjOECPW": true,
      "https://open.spotify.com/playlist/37i9dQZF1DX9EM98aZosoy?si=dxpmMMo-R7G9Xi87KL4OhQ":
          true,
      "https://open.spotify.com/playlist/37i9dQZF1DWWllhYl3ZMvY": false,
      "https://open.spotify.com/playlist/37i9dQZF1DXss1oenSJRJd?si=vb0S0kgKRkWOtj-Bmro28w":
          false
    };
    for (String url in urlsToTest.keys) {
      expect(await Spotify.playlistExists(url), urlsToTest[url]);
    }
  });
  test("test spotify playlist extraction", () async {
    expect(
      (await Spotify().getPlaylist("37i9dQZEVXbMDoHDwVN2tF",
              updateStrategy: PlaylistUpdateStrategy.FULL_FETCH))!
          .song_ids
          .length,
      50,
    );
    expect(
      (await Spotify().getPlaylist("71Oc23mUiQmiM3SNYkmvV1",
              updateStrategy: PlaylistUpdateStrategy.FULL_FETCH))!
          .song_ids
          .length,
      200,
    );
  });
}

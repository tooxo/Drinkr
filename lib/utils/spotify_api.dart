import 'dart:convert';

import 'package:Drinkr/utils/sqlite.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';

class Song {
  String name;
  String previewUrl;
  String id;

  Song(this.name, this.previewUrl, this.id);
}

class Playlist {
  String id;
  String name;
  String creator_name;
  String image_url;
  List<String> song_ids;
  DateTime last_update;

  Playlist(this.id, this.name, this.creator_name, this.image_url, this.song_ids,
      this.last_update);
}

class Spotify {
  // can reasonably be dumped here, the key is nothing important and not used
  // anywhere else. stealing it would be useless and completely harmless
  String authString =
      "YTU2OWEwZDczMjEwNGYyOTkyYmFiNTA4Y2YyNzhmNzY6MGQ0ZDhhOGQ2NTc0NDVhOThlN2Y3N2FlNmI1MzgyODk=";

  static const String REGEX_PLAYLIST =
      r"(https?://)?(open\.|play\.)spotify\.com/(user/.{,32}/)?(playlist)/([A-Za-z0-9]{22})(\?|$)(si=.{22,23})?\s?";

  static const String REGEX_EMBED = r'"preview_url":"([^"]+)"';

  String authKey = "";
  static const REQUEST_TOKEN_URL = "https://accounts.spotify.com/api/token";
  DateTime lastKeyRequest;

  static String getIdFromUrl(String url) {
    RegExp regExp = RegExp(REGEX_PLAYLIST);
    return regExp.firstMatch(url)?.group(5);
  }

  static Future<bool> playlistExists(String playlistUrl) async {
    return (await http.head(playlistUrl)).statusCode == 200;
  }

  Future<String> generateAuthKey() async {
    if (this.authKey != "") {
      if (lastKeyRequest.difference(DateTime.now()).inMinutes < 50) {
        return this.authKey;
      }
    }
    http.Response response = await http.post(REQUEST_TOKEN_URL,
        headers: {
          "Authorization": "Basic $authString",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: "grant_type=client_credentials&undefined=");
    Map<dynamic, dynamic> jsonResponse = jsonDecode(response.body);
    this.authKey = jsonResponse["access_token"];
    this.lastKeyRequest = DateTime.now();
    return jsonResponse["access_token"];
  }

  /// Pulls a playlist from Spotify
  Future<List<Song>> getPlaylist(String playlistId, {bool useCache = true}) async {
    List<Song> trackList = [];

    SqLite database;
    if (useCache) database = await SqLite().open();

    String token = await generateAuthKey();
    String url =
        "https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=100&offset=0";

    Map<String, dynamic> jsonResponse;
    do {
      http.Response response =
          await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode != 200) {
        return trackList;
      }
      jsonResponse = jsonDecode(response.body);
      for (Map<String, dynamic> track in jsonResponse["items"]) {
        if (track["is_local"]) {
          continue;
        }
        if (track["track"] == null) {
          continue;
        }

        Song song = Song(
            track["track"]["artists"][0]["name"] +
                " - " +
                track["track"]["name"],
            track["track"]["preview_url"],
            track["track"]["id"]);

        trackList.add(song);
      }
      url = jsonResponse["next"];
    } while (jsonResponse["next"] != null);

    if (useCache) unawaited(database.putBulkInSpotifyCache(trackList));
    return trackList;
  }

  Future<Song> fillMissingPreviewUrls(Song track, SqLite database,
      {bool useCache = true}) async {
    /// this fixes a weird error with spotify returning null as
    /// the preview url, although they have a preview available
    /// this also multiplies the time a playlist gets extracted by factor 50
    /// spotify big suck
    /// Documented here: https://github.com/spotify/web-api/issues/148

    Song fromDatabase =
        useCache ? await database.getFromSpotifyCache(track.id) : null;

    if (fromDatabase != null) {
      track.previewUrl = fromDatabase.previewUrl;
    } else {
      try {
        String trackId = track.id;

        /// Load the Embed Page via normal http page request
        http.Response embedResponse = await http.get(
          "https://open.spotify.com/embed/track/$trackId",
        );

        /// Extract the preview url via regex
        String previewUrl =
            RegExp(REGEX_EMBED).firstMatch(embedResponse.body).group(1);
        if (previewUrl != null) {
          /// Un-Escape the url
          previewUrl = previewUrl.replaceAll("\\/", "/");
        }
        track.previewUrl = previewUrl;

        /// put the newly found url in cache
        if (useCache) unawaited(database.putBulkInSpotifyCache([track]));
      } catch (_) {
        return Song(null, null, null);
      }
    }
    return track;
  }
}

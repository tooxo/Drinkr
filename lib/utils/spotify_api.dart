import 'dart:convert';

import 'package:Drinkr/utils/sqlite.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';

class Spotify {
  // can reasonably dumped here, the key is nothing important and not used
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
  Future<List<List<String>>> getPlaylist(String playlistId,
      {useCache = true}) async {
    List<List<String>> trackList = List<List<String>>();

    SqLite database;
    if (useCache) database = await SqLite().open();

    /// Start with pulling the embed web page, because spotify is shit.

    // Disabled for now, because it creates a way too great delay
    /*
    http.Response embedPlaylistResponse =
        await http.get("https://open.spotify.com/embed/playlist/$playlistId");

    var document = parse(embedPlaylistResponse.body);
    String rawJson = document.getElementById("resource").innerHtml.trim();

    dynamic decodedEmbedPage = jsonDecode(rawJson);
    for (Map<dynamic, dynamic> track in decodedEmbedPage["tracks"]["items"]) {
      if (track["track"]["preview_url"] != null) {
        track["track"]["preview_url"] =
            track["track"]["preview_url"].replaceAll("\\/", "/");
      }
      List<String> song = [
        track["track"]["artists"][0]["name"] + " - " + track["track"]["name"],
        track["track"]["preview_url"],
        track["track"]["id"]
      ];
      if (!song.contains(null)) {
        trackList.add(song);
      }
    }
    */

    //  if (decodedEmbedPage["tracks"]["total"] > 100) {
    String token = await generateAuthKey();
    String url =
        "https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=100&offset=0";

    Map<dynamic, dynamic> jsonResponse;
    do {
      http.Response response =
          await http.get(url, headers: {"Authorization": "Bearer $token"});
      if (response.statusCode != 200) {
        return trackList;
      }
      jsonResponse = jsonDecode(response.body);
      for (Map<dynamic, dynamic> track in jsonResponse["items"]) {
        if (track["is_local"]) {
          continue;
        }
        if (track["track"] == null) {
          continue;
        }

        List<String> song = [
          track["track"]["artists"][0]["name"] + " - " + track["track"]["name"],
          track["track"]["preview_url"],
          track["track"]["id"]
        ];

        // if (!song.contains(null)) {
        trackList.add(song);
        // }
      }
      url = jsonResponse["next"];
    } while (jsonResponse["next"] != null);
    //}
    if (useCache) unawaited(database.putBulkInSpotifyCache(trackList));
    return trackList;
  }

  Future<List<String>> fillMissingPreviewUrls(
      List<String> track, SqLite database,
      {useCache = true}) async {
    /// this fixes a weird error with spotify returning null as
    /// the preview url, although they have a preview available
    /// this also multiplies the time a playlist gets extracted by factor 50
    /// spotify big suck
    /// Documented here: https://github.com/spotify/web-api/issues/148

    String previewFromDatabase =
        useCache ? await database.getFromSpotifyCache(track[2]) : null;

    if (previewFromDatabase != null) {
      track[1] = previewFromDatabase;
    } else {
      try {
        String trackId = track[2];
        http.Response embedResponse = await http.get(
          "https://open.spotify.com/embed/track/$trackId",
        );
        String previewUrl =
            RegExp(REGEX_EMBED).firstMatch(embedResponse.body).group(1);
        if (previewUrl != null) {
          previewUrl = previewUrl.replaceAll("\\/", "/");
        }
        track[1] = previewUrl;
      } catch (ignored) {
        return [null, null, null];
      }
    }
    return track;
  }
}

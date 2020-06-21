import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Spotify {
  // can reasonably dumped here, the key is nothing important and not used
  // anywhere else. stealing it would be useless and completely harmless
  String authString =
      "YTU2OWEwZDczMjEwNGYyOTkyYmFiNTA4Y2YyNzhmNzY6MGQ0ZDhhOGQ2NTc0NDVhOThlN2Y3N2FlNmI1MzgyODk=";

  static const String REGEX_PLAYLIST =
      r"(https?://)?(open\.|play\.)spotify\.com/(user/.{,32}/)?(playlist)/([A-Za-z0-9]{22})(\?|$)(si=.{22,23})?\s?";

  String authKey = "";
  static const REQUEST_TOKEN_URL = "https://accounts.spotify.com/api/token";
  DateTime lastKeyRequest;

  static String getIdFromUrl(String url) {
    RegExp regExp = new RegExp(REGEX_PLAYLIST);
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
  Future<List<List<String>>> getPlaylist(String playlistId) async {
    String token = await generateAuthKey();

    String url =
        "https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=100&offset=0";

    List<List<String>> trackList = new List<List<String>>();
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
          track["track"]["preview_url"]
        ];
        if (!song.contains(null)) {
          trackList.add(song);
        }
        url = jsonResponse["next"];
      }
    } while (jsonResponse.containsKey("more"));
    return trackList;
  }
}

import 'dart:convert';

import 'package:drinkr/utils/spotify_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pedantic/pedantic.dart';

part 'spotify_api.g.dart';

@HiveType(typeId: 1)
class Song {
  @HiveField(0)
  String name;
  @HiveField(1)
  String? previewUrl;
  @HiveField(2)
  String id;

  Song(this.name, this.previewUrl, this.id);
}

@HiveType(typeId: 2)
class Playlist with Comparable<Playlist> {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String creatorName;
  @HiveField(3)
  String imageUrl;
  @HiveField(4)
  List<String> songIds = [];
  @HiveField(5)
  String snapshotId;
  @HiveField(6)
  DateTime lastFetch;
  @HiveField(7)
  bool enabled;
  @HiveField(8)
  bool included;

  String get url => "https://open.spotify.com/playlist/$id";

  Playlist({
    required this.id,
    required this.name,
    required this.creatorName,
    required this.imageUrl,
    required this.snapshotId,
    required this.lastFetch,
    required this.enabled,
    required this.included,
  });

  @override
  int compareTo(Playlist other) {
    return name.toLowerCase().compareTo(other.name.toLowerCase());
  }
}

enum PlaylistUpdateStrategy {
  trustCache,
  checkForUpdateTimestamp,
  checkForUpdateSnapshotId,
  fullFetch
}

class Spotify {
  // can reasonably be dumped here, the key is nothing important and not used
  // anywhere else. stealing it would be useless and completely harmless
  String authString =
      "YTU2OWEwZDczMjEwNGYyOTkyYmFiNTA4Y2YyNzhmNzY6MGQ0ZDhhOGQ2NTc0NDVhOThlN2Y3N2FlNmI1MzgyODk=";

  static const String regexPlaylist =
      r"(https?://)?(open\.|play\.)spotify\.com/(user/.{,32}/)?(playlist)/([A-Za-z0-9]{22})(\?|$)(si=.{22,23})?\s?";

  static const String regexEmbed = r'"preview_url":"([^"]+)"';

  String authKey = "";
  static const requestTokenUrl = "https://accounts.spotify.com/api/token";
  DateTime? lastKeyRequest;

  static final Spotify _instance = Spotify._privateConstructor();

  Spotify._privateConstructor();

  factory Spotify() => _instance;

  static String? getIdFromUrl(String url) {
    RegExp regExp = RegExp(regexPlaylist);
    return regExp.firstMatch(url)?.group(5);
  }

  static Future<bool> playlistExists(String playlistUrl) async {
    return (await http.head(Uri.parse(playlistUrl))).statusCode == 200;
  }

  Future<String> generateAuthKey() async {
    if (authKey != "") {
      if (lastKeyRequest!.difference(DateTime.now()).inMinutes < 50) {
        return authKey;
      }
    }
    http.Response response = await http.post(
      Uri.parse(requestTokenUrl),
      headers: {
        "Authorization": "Basic $authString",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "grant_type=client_credentials&undefined=",
    );
    Map<String, dynamic> jsonResponse = json.decode(response.body);
    authKey = jsonResponse["access_token"];
    lastKeyRequest = DateTime.now();
    return jsonResponse["access_token"];
  }

  Future<Playlist?> getPlaylistWithoutSongs(
    String playlistId, {
    bool included = true,
  }) async {
    Playlist? cachePlaylist =
        SpotifyStorage.getPlaylistFromSpotifyCache(playlistId);

    String token = await generateAuthKey();
    String infoUrl = "https://api.spotify.com/v1/playlists/$playlistId/";

    http.Response infoResponse = await http
        .get(Uri.parse(infoUrl), headers: {"Authorization": "Bearer $token"});
    if (infoResponse.statusCode != 200) {
      return null;
    }

    Map<String, dynamic> infoJsonResponse = jsonDecode(infoResponse.body);
    Playlist playlist = Playlist(
      id: playlistId,
      creatorName: infoJsonResponse["owner"]["id"],
      imageUrl: infoJsonResponse["images"][0]["url"],
      name: infoJsonResponse["name"],
      snapshotId: infoJsonResponse["snapshot_id"],
      lastFetch: DateTime.fromMillisecondsSinceEpoch(0),
      enabled: cachePlaylist?.enabled ?? true,
      included: included,
    );
    return playlist;
  }

  /// Pulls a playlist from Spotify
  Future<Playlist?> getPlaylist(String playlistId,
      {PlaylistUpdateStrategy updateStrategy =
          PlaylistUpdateStrategy.checkForUpdateTimestamp}) async {
    Playlist? cachePlaylist =
        SpotifyStorage.getPlaylistFromSpotifyCache(playlistId);
    if (cachePlaylist != null) {
      if (updateStrategy == PlaylistUpdateStrategy.trustCache &&
          cachePlaylist.lastFetch.millisecondsSinceEpoch != 0) {
        return cachePlaylist;
      }

      // return if last fetch is closer than 24 hours
      if (updateStrategy == PlaylistUpdateStrategy.checkForUpdateTimestamp) {
        if (cachePlaylist.lastFetch.difference(DateTime.now()).abs().inHours <
            24) {
          return cachePlaylist;
        }
      }
    }

    String token = await generateAuthKey();
    String infoUrl = "https://api.spotify.com/v1/playlists/$playlistId/";
    String? url = infoUrl + "tracks?limit=100&offset=0";

    http.Response infoResponse = await http
        .get(Uri.parse(infoUrl), headers: {"Authorization": "Bearer $token"});
    if (infoResponse.statusCode != 200) {
      return null;
    }

    Map<String, dynamic> infoJsonResponse = jsonDecode(infoResponse.body);
    Playlist playlist = Playlist(
      id: playlistId,
      creatorName: infoJsonResponse["owner"]["id"],
      imageUrl: infoJsonResponse["images"][0]["url"],
      name: infoJsonResponse["name"],
      snapshotId: infoJsonResponse["snapshot_id"],
      lastFetch: DateTime.now(),
      enabled: cachePlaylist?.enabled ?? true,
      included: cachePlaylist?.included ?? false,
    );

    if (updateStrategy == PlaylistUpdateStrategy.checkForUpdateSnapshotId &&
        cachePlaylist != null) {
      if (cachePlaylist.snapshotId == playlist.snapshotId) {
        return cachePlaylist;
      }
    }

    List<Song> songs = [];
    Map<String, dynamic> jsonResponse;
    do {
      http.Response response = await http
          .get(Uri.parse(url!), headers: {"Authorization": "Bearer $token"});
      if (response.statusCode != 200) {
        return null;
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

        songs.add(song);
        playlist.songIds.add(song.id);
      }
      url = jsonResponse["next"];
    } while (jsonResponse["next"] != null);

    await SpotifyStorage.putBulkInSpotifyCache(songs);
    await SpotifyStorage.putBulkInSpotifyPlaylistCache([playlist]);
    return playlist;
  }

  Future<Song?> fillMissingPreviewUrls(Song track,
      {bool useCache = true}) async {
    /// this fixes a weird error with spotify returning null as
    /// the preview url, although they have a preview available
    /// this also multiplies the time a playlist gets extracted by factor 50
    /// spotify big suck
    /// Documented here: https://github.com/spotify/web-api/issues/148

    Song? fromDatabase =
        useCache ? await SpotifyStorage.getFromSpotifyCache(track.id) : null;

    if (fromDatabase != null) {
      track.previewUrl = fromDatabase.previewUrl;
    } else {
      try {
        String trackId = track.id;

        /// Load the Embed Page via normal http page request
        http.Response embedResponse = await http.get(
          Uri.parse("https://open.spotify.com/embed/track/$trackId"),
        );

        /// Extract the preview url via regex
        String? previewUrl =
            RegExp(regexEmbed).firstMatch(embedResponse.body)!.group(1);
        if (previewUrl != null) {
          /// Un-Escape the url
          previewUrl = previewUrl.replaceAll("\\/", "/");
        }
        track.previewUrl = previewUrl;

        /// put the newly found url in cache
        if (useCache) unawaited(SpotifyStorage.putBulkInSpotifyCache([track]));
      } catch (_) {
        return null;
      }
    }
    return track;
  }
}

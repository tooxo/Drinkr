import 'package:Drinkr/utils/spotify_api.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqLite {
  static const String DATABASE_NAME = "spotify_cache.db";
  Database database;

  Future<SqLite> open() async {
    if (database == null) {
      database =
          await openDatabase(join(await getDatabasesPath(), DATABASE_NAME),
              onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE playlists(id TEXT PRIMARY KEY, name TEXT, creator_name TEXT, image_url TEXT, ids TEXT, last_change INTEGER)");
        return await db.execute(
            "CREATE TABLE songs(id TEXT PRIMARY KEY, preview_url TEXT, title TEXT)");
      }, version: 1);
    }
    return this;
  }

  Future<void> close() async => await database.close();

  Future<Song> getFromSpotifyCache(String songId) async {
    List<Map<String, dynamic>> returnValue =
        await database.query("songs", where: "id = ?", whereArgs: [songId]);
    if (returnValue.isNotEmpty) {
      return Song(returnValue[0]["name"], returnValue[0]["preview_url"],
          returnValue[0]["id"]);
    } else {
      return null;
    }
  }

  Future<void> putBulkInSpotifyCache(Iterable<Song> songs) async {
    Batch batch = database.batch();
    for (Song song in songs) {
      batch.insert("songs",
          {"id": song.id, "preview_url": song.previewUrl, "title": song.name},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> putBuilkInSpotifyPlaylistCache(
      Iterable<Playlist> playlists) async {}
}

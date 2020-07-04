import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqLite {
  static const String DATABASE_NAME = "spotify_cache.db";
  Database database;

  Future<SqLite> open() async {
    if (database == null) {
      database =
          await openDatabase(join(await getDatabasesPath(), DATABASE_NAME),
              onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE songs(id TEXT PRIMARY KEY, preview_url TEXT)");
      }, version: 1);
    }
    return this;
  }

  Future<void> close() async => await database.close();

  Future<String> getFromSpotifyCache(String songId) async {
    dynamic returnValue =
        await database.query("songs", where: "id = ?", whereArgs: [songId]);
    if (returnValue.isNotEmpty) {
      return returnValue[0]["preview_url"];
    } else {
      return null;
    }
  }

  Future<void> putInSpotifyCache(String songId, String previewUrl) async {
    await database.insert("songs", {"id": songId, "preview_url": previewUrl},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> putBulkInSpotifyCache(List<List<String>> songs) async {
    /// List[0] title of song (discard)
    /// List[1] preview url
    /// List[2] spotify id

    Batch batch = database.batch();
    for (List<String> song in songs) {
      batch.insert("songs", {"id": song[2], "preview_url": song[1]},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}

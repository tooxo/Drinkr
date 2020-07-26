import 'dart:convert';
import 'dart:io';

import 'package:Drinkr/utils/types.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  return (await getApplicationDocumentsDirectory()).path;
}

class SupportedLanguages {
  static const Locale de = Locale.fromSubtags(languageCode: "de");
  static const Locale en = Locale.fromSubtags(languageCode: "en");
}

class InvalidTypeException implements Exception {}

/// Get a list of all files included in the application files
Future<Map<String, dynamic>> _parseManifest(BuildContext context) async {
  String manifestContent =
      await DefaultAssetBundle.of(context).loadString("AssetManifest.json");
  return json.decode(manifestContent);
}

/// Get a list of all FilePaths in local Documents.
Future<List<String>> _getLocalFiles() async {
  Directory documents = new Directory(await _localPath);
  List<String> filePaths = List<String>();
  dynamic test = await documents
      .list(recursive: true, followLinks: false)
      .where((event) => event is File)
      .toList();
  for (File file in test) {
    filePaths.add(file.path);
  }
  return filePaths.where((element) => element.trim() != "").toList();
}

/// Loads a String from a File located at [path]
Future<String> _loadManifestAsset(BuildContext context, String path) async {
  return await DefaultAssetBundle.of(context).loadString(path);
}

/// Loads a String from a local File located at [path]
Future<String> _loadLocalFile(String path) async {
  File f = File(path);
  return await f.readAsString();
}

/// Gets the in the game included, not custom, lines by Type [type] for
/// Locale [locale] and returns them in a line by line list.
/// The [context] is required to receive local files.
Future<List<String>> getIncludedFiles(
    GameType type, BuildContext context) async {
  String gameType = gameTypeToGameTypeClass(type).filePrefix;

  Locale currentLocale = Localizations.localeOf(context);
  String locale = currentLocale.languageCode;

  // create the complete path for the file[s] requested.
  String path = "assets/text/$locale/$gameType";
  List<String> matchingFilenames = (await _parseManifest(context))
      .keys
      .where((element) => element.startsWith(path))
      .toList();
  List<String> returnValue = List<String>();
  for (String fileName in matchingFilenames) {
    String fileContent = await _loadManifestAsset(context, fileName);
    fileContent.split("\n").forEach((element) {
      if (element.isNotEmpty && element != "") {
        if (element.endsWith("\r")) {
          element.replaceAll("\r", "");
        }
        returnValue.add(element);
      }
    });
  }
  return returnValue.where((element) => element.trim() != "").toList();
}

/// Gets lines by Type [type] from local files, for example custom
/// files and returns them in a line by line list.
Future<List<String>> getLocalFiles(GameType type) async {
  String gameType = gameTypeToGameTypeClass(type).filePrefix;
  String pathMatcher = "/customFiles/$gameType";
  List<String> returnValue = List<String>();
  for (String fileName in (await _getLocalFiles())
      .where((element) => element.contains(pathMatcher))) {
    String documentContent = await _loadLocalFile(fileName);
    documentContent.split("\n").forEach((split) {
      returnValue.add(split);
    });
  }
  return returnValue.where((element) => element.trim() != "").toList();
}

/// Count the texts in all files from Locale [locale] with enabled games [enabledGames]
Future<int> getNumberOfTexts(
    List<GameType> enabledGames, BuildContext context) async {
  int returnValue = 0;
  for (GameType type in enabledGames) {
    returnValue += (await getIncludedFiles(type, context)).length;
  }
  return returnValue;
}

/// Count the user added texts in all files with enabled games [enabledGames]
Future<int> getNumberOfTextsLocal(
    {List<GameType> enabledGames = GameType.values}) async {
  int returnValue = 0;
  for (GameType type in enabledGames) {
    returnValue += (await getLocalFiles(type))
        .where((element) => element.trim() != "")
        .toList()
        .length;
  }
  return returnValue;
}

/// Append a custom line to the custom file in the local folder
Future<bool> appendCustomLines(
    List<String> linesToAppend, GameType gameType) async {
  // Get correct file to append to
  String typeString = gameTypeToGameTypeClass(gameType).filePrefix;
  File file = File((await _localPath) + "/customFiles/$typeString.custom.txt");

  // Create file, if not already there
  if (!file.existsSync()) {
    await file.create(recursive: true);
  }

  // Add a \n to the end of the file, if it isn't already there, so
  // that not more than one text is on one line
  if (!(await file.readAsString()).endsWith("\n")) {
    await file.writeAsString("\n", mode: FileMode.append);
  }

  // Put the content in already
  for (String line in linesToAppend) {
    await file.writeAsString(line + "\n", mode: FileMode.append);
  }
  return true;
}

/// Remove (multiple) custom lines [linesToRemove] from the file corresponding to
/// GameType [gameType]
Future<bool> removeCustomLines(
    List<String> linesToRemove, GameType gameType) async {
  // Get correct file to remove from
  String typeString = gameTypeToGameTypeClass(gameType).filePrefix;
  File file = File((await _localPath) + "/customFiles/$typeString.custom.txt");

  // If the file does not exist, there is nothing to delete --'
  if (!file.existsSync()) {
    return false;
  }

  // Filter out the lines in linesToRemove
  List<String> newFileContent = (await file.readAsLines()).where((element) {
    for (String line in linesToRemove) {
      if (element == line) {
        return false;
      }
    }
    return true;
  }).toList();

  // Concat the lines with newlines in between
  String fileContentString = newFileContent.join("\n");

  // Write the new content to the file.
  await file.writeAsString(fileContentString);
  return true;
}

/// Add (multiple) [blacklistedLines] to the file corresponding to GameType [gameType]
Future<bool> addBlacklistedLines(
    List<String> blacklistedLines, GameType gameType) async {
  String typeString = gameTypeToGameTypeClass(gameType).filePrefix;
  File file =
      File((await _localPath) + "/blacklistFiles/$typeString.blacklist.txt");

  if (!file.existsSync()) {
    return false;
  }

  // Add a \n to the end of the file, if it isn't already there, so
  // that not more than one text is on one line
  if (!(await file.readAsString()).endsWith("\n")) {
    await file.writeAsString("\n", mode: FileMode.append);
  }

  // Put the content in already
  for (String line in blacklistedLines) {
    await file.writeAsString(line + "\n", mode: FileMode.append);
  }
  return true;
}

/// Remove (multiple) [blacklistedLines] from the file corresponding to GameType [gameType]
Future<bool> removeBlacklistedLines(
    List<String> blacklistedLines, GameType gameType) async {
  String typeString = gameTypeToGameTypeClass(gameType).filePrefix;
  File file =
      File((await _localPath) + "/blacklistFiles/$typeString.blacklist.txt");

  // If the file does not exist, there is nothing to delete --'
  if (!file.existsSync()) {
    return false;
  }

  // Filter out the lines in linesToRemove
  List<String> newFileContent = (await file.readAsLines()).where((element) {
    for (String line in blacklistedLines) {
      if (element == line) {
        return false;
      }
    }
    return true;
  }).toList();

  // Concat the lines with newlines in between
  String fileContentString = newFileContent.join("\n");

  // Write the new content to the file.
  await file.writeAsString(fileContentString);
  return true;
}

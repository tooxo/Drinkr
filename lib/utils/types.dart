import 'package:drinkr/games/challenges.dart';
import 'package:drinkr/games/game.dart';
import 'package:drinkr/games/guess_the_song.dart';
import 'package:drinkr/games/guessing.dart';
import 'package:drinkr/games/never_have_i_ever.dart';
import 'package:drinkr/games/opinion.dart';
import 'package:drinkr/games/quiz.dart';
import 'package:drinkr/games/truth_or_dare.dart';
import 'package:drinkr/games/who_would_rather.dart';
import 'package:drinkr/utils/difficulty.dart';
import 'package:drinkr/utils/player.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum GameType {
  quiz,
  challenges,
  neverHaveIEver,
  opinion,
  guess,
  guessTheSong,
  truth,
  dare,
  whoWouldRather,
  undefined
}

class BaseType {}

abstract class TypeClass<T extends BaseType> {
  Color get primaryColor;

  Color get secondaryColor;

  String get translatedTitle;

  String get filePrefix;

  bool get hasSolution;

  GameType get type;

  String get text1;

  String get text2;

  bool get includesPlayers;

  bool get singlePlayerActivity;

  bool get hasAdultQuestions;

  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction;
}

class QuizType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(2, 119, 189, 1);

  @override
  Color secondaryColor = Color.fromRGBO(88, 165, 240, 1);

  @override
  String get translatedTitle => "bigBrainQuiz".tr();
  @override
  String filePrefix = "qui";
  @override
  bool hasSolution = true;
  @override
  GameType type = GameType.quiz;

  @override
  String get text1 => "quizText1".tr();

  @override
  String get text2 => "quizText2".tr();

  @override
  bool includesPlayers = true;
  @override
  bool singlePlayerActivity = true;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction =>
          (player, difficulty, message) => Quiz(player, difficulty, message);

  @override
  bool hasAdultQuestions = false;
}

class TruthType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(255, 23, 68, 1);

  @override
  Color secondaryColor = Color.fromRGBO(255, 89, 104, 1);

  @override
  String get translatedTitle => "truth".tr();
  @override
  String filePrefix = "tru";

  @override
  bool hasSolution = false;
  @override
  GameType type = GameType.truth;

  @override
  String get text1 => "truthText1".tr();

  @override
  String get text2 => "truthText2".tr();

  @override
  bool includesPlayers = true;
  @override
  bool singlePlayerActivity = true;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => (players, difficulty, message) =>
          TruthOrDare(players, difficulty, message);

  @override
  bool hasAdultQuestions = true;
}

class DareType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(255, 23, 68, 1);
  @override
  Color secondaryColor = Color.fromRGBO(255, 89, 104, 1);

  @override
  String get translatedTitle => "dare".tr();
  @override
  String filePrefix = "dar";

  @override
  bool hasSolution = false;
  @override
  GameType type = GameType.dare;

  @override
  String get text1 => "dareText1".tr();

  @override
  String get text2 => "dareText2".tr();

  @override
  bool includesPlayers = true;
  @override
  bool singlePlayerActivity = true;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => throw UnimplementedError();

  @override
  bool hasAdultQuestions = true;
}

class ChallengesType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(0, 150, 136, 1);
  @override
  Color secondaryColor = Color.fromRGBO(82, 199, 184, 1);

  @override
  String get translatedTitle => "challenges".tr();
  @override
  String filePrefix = "cha";

  @override
  bool hasSolution = false;
  @override
  GameType type = GameType.challenges;

  @override
  String get text1 => "challengesText1".tr();

  @override
  String get text2 => "challengesText2".tr();

  @override
  bool includesPlayers = true;
  @override
  bool singlePlayerActivity = false;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => (players, difficulty, message) =>
          Challenges(players, difficulty, message);

  @override
  bool hasAdultQuestions = true;
}

class NeverHaveIEverType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(211, 47, 47, 1);

  @override
  Color secondaryColor = Color.fromRGBO(255, 102, 89, 1);

  @override
  String get translatedTitle => "neverHaveIEver".tr();
  @override
  String filePrefix = "nhi";

  @override
  bool hasSolution = false;
  @override
  GameType type = GameType.neverHaveIEver;

  @override
  String get text1 => "neverHaveIEverText1".tr();

  @override
  String get text2 => "neverHaveIEverText2".tr();

  @override
  bool includesPlayers = false;
  @override
  bool singlePlayerActivity = false;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction =>
          (Player player, DifficultyType difficulty, String text) =>
              NeverHaveIEver(player, difficulty, text);

  @override
  bool hasAdultQuestions = true;
}

class WouldYouRatherType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(253, 216, 53, 1);

  @override
  Color secondaryColor = Color.fromRGBO(255, 255, 107, 1);

  @override
  String get translatedTitle => "wouldYouRather".tr();
  @override
  String filePrefix = "opi";

  @override
  bool hasSolution = false;
  @override
  GameType type = GameType.opinion;

  @override
  String get text1 => "opinionText1".tr();

  @override
  String get text2 => "opinionText2".tr();

  @override
  bool includesPlayers = false;
  @override
  bool singlePlayerActivity = false;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => (players, difficulty, message) =>
          Opinion(players, difficulty, message);
  @override
  bool hasAdultQuestions = false;
}

class OpinionType extends WouldYouRatherType {
  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => (players, difficulty, message) =>
          Opinion(players, difficulty, message);

  @override
  bool hasAdultQuestions = true;
}

class GuessingType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(156, 39, 176, 1);

  @override
  Color secondaryColor = Color.fromRGBO(208, 92, 227, 1);

  @override
  String get translatedTitle => "guessing".tr();
  @override
  String filePrefix = "gue";

  @override
  bool hasSolution = true;
  @override
  GameType type = GameType.guess;

  @override
  String get text1 => "guessingText1".tr();

  @override
  String get text2 => "guessingText2".tr();

  @override
  bool includesPlayers = false;
  @override
  bool singlePlayerActivity = false;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => (players, difficulty, message) =>
          Guessing(players, difficulty, message);

  @override
  bool hasAdultQuestions = false;
}

class WhoWouldRatherType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(156, 39, 176, 1);

  @override
  Color secondaryColor = Color.fromRGBO(208, 92, 227, 1);

  @override
  String get translatedTitle => "whoWouldRather".tr();
  @override
  String filePrefix = "wwr";

  @override
  bool hasSolution = false;
  @override
  GameType type = GameType.whoWouldRather;

  @override
  String get text1 => "whoWouldRatherText1".tr();

  @override
  String get text2 => "whoWouldRatherText2".tr();

  @override
  bool includesPlayers = false;
  @override
  bool singlePlayerActivity = false;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => (players, difficulty, message) =>
          WhoWouldRather(players, difficulty, message);

  @override
  bool hasAdultQuestions = false;
}

class GuessTheSongType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Color.fromRGBO(46, 125, 50, 1);
  @override
  Color secondaryColor = Color.fromRGBO(96, 173, 94, 1);

  @override
  String get translatedTitle => "guessTheSong".tr();
  @override
  String filePrefix = "gts";

  @override
  bool hasSolution = false;
  @override
  GameType type = GameType.guessTheSong;

  @override
  String get text1 => "guessTheSongText1".tr();

  @override
  String get text2 => "guessTheSongText2".tr();

  @override
  bool includesPlayers = false;
  @override
  bool singlePlayerActivity = false;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => (players, difficulty, message) =>
          GuessTheSong(players, difficulty, message);

  @override
  bool hasAdultQuestions = false;
}

class UnknownType extends TypeClass<BaseType> {
  @override
  Color primaryColor = Colors.black;
  @override
  Color secondaryColor = Colors.black;

  @override
  String get translatedTitle => "";
  @override
  String filePrefix =
      "jquBefzYYCgFerAjnt9XUahnATF4GbsFyQXuKrPejmMJwmGWtVsuJ6x94marBPty";

  @override
  bool hasSolution = false;
  @override
  GameType type = GameType.undefined;

  @override
  String get text1 => "";

  @override
  String get text2 => "";

  @override
  bool includesPlayers = false;
  @override
  bool singlePlayerActivity = false;

  @override
  BasicGame Function(Player player, DifficultyType difficulty, String text)
      get constructorFunction => throw UnimplementedError();

  @override
  bool hasAdultQuestions = false;
}

TypeClass<BaseType> gameTypeToGameTypeClass(GameType gameType) {
  switch (gameType) {
    case GameType.quiz:
      return QuizType();
    case GameType.challenges:
      return ChallengesType();
    case GameType.neverHaveIEver:
      return NeverHaveIEverType();
    case GameType.opinion:
      return OpinionType();
    case GameType.guess:
      return GuessingType();
    case GameType.guessTheSong:
      return GuessTheSongType();
    case GameType.truth:
      return TruthType();
    case GameType.dare:
      return DareType();
    case GameType.whoWouldRather:
      return WhoWouldRatherType();
    case GameType.undefined:
      return UnknownType();
    default:
      return UnknownType();
  }
}

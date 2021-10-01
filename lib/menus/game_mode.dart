import 'dart:async';

import 'package:drinkr/utils/custom_icons.dart';
import 'package:drinkr/utils/player.dart';
import 'package:drinkr/utils/purchases.dart';
import 'package:drinkr/utils/types.dart';
import 'package:drinkr/widgets/custom_game_select_tile.dart';
import 'package:drinkr/widgets/game_select_tile.dart';
import 'package:drinkr/widgets/purchasable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/types.dart';

class GameMode extends StatefulWidget {
  final List<Player> players;

  const GameMode(this.players, {Key? key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

enum CurrentGameState { stopped, loading, inGame }
enum PurchaseState { available, inProgress, done }

class GameState extends State<GameMode> {
  CurrentGameState gameState = CurrentGameState.stopped;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  void onStateChange(CurrentGameState newState) {
    setState(() {
      gameState = newState;
    });
  }

  PurchaseState purchaseState = PurchaseState.available;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      // handle error here.
    });

    Purchases.isPremiumPurchased().then(
      (bool value) => {
        setState(() {
          if (purchaseState == PurchaseState.available && value) {
            purchaseState = PurchaseState.done;
          }
        })
      },
    );

    super.initState();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    // ignore: avoid_function_literals_in_foreach_calls
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          purchaseState = PurchaseState.inProgress;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("purchase error");
          setState(() {
            purchaseState = PurchaseState.available;
          });
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            purchaseState = PurchaseState.done;
          });
          await Purchases.setPremiumPurchased();
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<GameType> enabledGamesCustom = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        title: Text(
          "gameModeSelect",
          style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ).tr(),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            children: [
              Divider(),
              GameSelectTile(
                enabled: gameState == CurrentGameState.stopped,
                backgroundColors: [
                  Color.fromRGBO(0xFE, 0x8C, 0x00, 1),
                  Color.fromRGBO(0xF8, 0x36, 0x00, 1)
                ],
                parentContext: context,
                onGameStateChange: onStateChange,
                title: "gameModeStandard",
                subtitle: "gameModeStandardDescription",
                icon: CustomIcons.gameModeStandard,
                players: widget.players,
                enabledGames: [
                  GameType.whoWouldRather,
                  GameType.truth,
                  GameType.neverHaveIEver,
                  GameType.opinion,
                  GameType.challenges,
                  GameType.quiz,
                  GameType.guess,
                  GameType.guessTheSong
                ],
              ),
              Divider(),
              GameSelectTile(
                enabled: gameState == CurrentGameState.stopped,
                backgroundColors: [
                  Color.fromRGBO(255, 27, 24, 1),
                  Color.fromRGBO(241, 61, 180, 1),
                ],
                parentContext: context,
                onGameStateChange: onStateChange,
                title: "gameModeParty",
                subtitle: "gameModePartyDescription",
                icon: CustomIcons.gameModeParty,
                players: widget.players,
                enabledGames: [
                  GameType.dare,
                  GameType.truth,
                  GameType.challenges,
                  GameType.neverHaveIEver,
                  GameType.opinion,
                  GameType.whoWouldRather
                ],
              ),
              Divider(),
              GameSelectTile(
                enabled: gameState == CurrentGameState.stopped,
                backgroundColors: [
                  Color.fromRGBO(79, 44, 208, 1),
                  Color.fromRGBO(7, 149, 199, 1),
                ],
                parentContext: context,
                onGameStateChange: onStateChange,
                title: "gameModeQuiz",
                subtitle: "gameModeQuizDescription",
                icon: CustomIcons.gameModeQuiz,
                players: widget.players,
                enabledGames: [
                  GameType.quiz,
                  GameType.guess,
                ],
              ),
              Divider(),
              GameSelectTile(
                enabled: gameState == CurrentGameState.stopped,
                backgroundColors: [
                  Color.fromRGBO(25, 96, 2, 1),
                  Color.fromRGBO(95, 154, 0, 1),
                ],
                parentContext: context,
                onGameStateChange: onStateChange,
                title: "gameModeSongGuess",
                subtitle: "gameModeSongGuessDescription",
                icon: CustomIcons.gameModeSong,
                players: widget.players,
                enabledGames: [
                  GameType.guessTheSong,
                ],
              ),
              Divider(),
              Purchasable(
                child: CustomGameSelectTile(
                  title: "gameModeCustom",
                  subtitle: "gameModeCustomDescription",
                  icon: CustomIcons.gameModeCustom,
                  players: widget.players,
                  enabledGames: enabledGamesCustom,
                  backgroundColors: [
                    Color.fromRGBO(131, 58, 180, 1),
                    Color.fromRGBO(253, 29, 29, 1),
                    Color.fromRGBO(253, 187, 45, 1),
                  ],
                  parentContext: context,
                  onGameStateChange: onStateChange,
                  enabled: gameState == CurrentGameState.stopped,
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}

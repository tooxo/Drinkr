import 'dart:async';

import 'package:drinkr/utils/custom_icons.dart';
import 'package:drinkr/utils/player.dart';
import 'package:drinkr/utils/purchases.dart';
import 'package:drinkr/utils/types.dart';
import 'package:drinkr/widgets/custom_game_select_tile.dart';
import 'package:drinkr/widgets/game_select_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/types.dart';

class GameMode extends StatefulWidget {
  final List<Player> players;

  static const IconData icon_custom =
      IconData(0xe800, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_guessthesong =
      IconData(0xe801, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_quiz =
      IconData(0xe802, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_dirty =
      IconData(0xe803, fontFamily: 'GameModeSelectionIcons', fontPackage: null);
  static const IconData icon_party =
      IconData(0xe804, fontFamily: 'GameModeSelectionIcons', fontPackage: null);

  const GameMode(this.players, {Key? key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

enum CurrentGameState { STOPPED, LOADING, IN_GAME }
enum PurchaseState { AVAILABLE, IN_PROGRESS, DONE }

class GameState extends State<GameMode> {
  CurrentGameState gameState = CurrentGameState.STOPPED;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  void onStateChange(CurrentGameState newState) {
    setState(() {
      gameState = newState;
    });
  }

  PurchaseState purchaseState = PurchaseState.AVAILABLE;

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
          if (purchaseState == PurchaseState.AVAILABLE && value) {
            purchaseState = PurchaseState.DONE;
          }
        })
      },
    );

    super.initState();
  }

  static const Set<String> purchaseIds = <String>{'premium'};

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          purchaseState = PurchaseState.IN_PROGRESS;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("purchase error");
          setState(() {
            purchaseState = PurchaseState.AVAILABLE;
          });
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            purchaseState = PurchaseState.DONE;
          });
          await Purchases.setPremiumPurchased();
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  void purchase() async {
    print("starting purchase process");
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(purchaseIds);
    if (response.notFoundIDs.isNotEmpty) {
      return;
    }
    List<ProductDetails> products = response.productDetails;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: products
          .where(
            (element) => element.id == "premium",
          )
          .first,
    );
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
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
                enabled: gameState == CurrentGameState.STOPPED,
                backgroundColors: [
                  Color.fromRGBO(0xFE, 0x8C, 0x00, 1),
                  Color.fromRGBO(0xF8, 0x36, 0x00, 1)
                ],
                parentContext: context,
                onGameStateChange: onStateChange,
                title: "gameModeStandard",
                subtitle: "gameModeStandardDescription",
                icon: CustomIcons.game_mode_standard,
                players: widget.players,
                enabledGames: [
                  GameType.WHO_WOULD_RATHER,
                  GameType.TRUTH,
                  GameType.NEVER_HAVE_I_EVER,
                  GameType.OPINION,
                  GameType.CHALLENGES,
                  GameType.QUIZ,
                  GameType.GUESS,
                  GameType.GUESS_THE_SONG
                ],
              ),
              Divider(),
              GameSelectTile(
                enabled: gameState == CurrentGameState.STOPPED,
                backgroundColors: [
                  Color.fromRGBO(255, 27, 24, 1),
                  Color.fromRGBO(241, 61, 180, 1),
                ],
                parentContext: context,
                onGameStateChange: onStateChange,
                title: "gameModeParty",
                subtitle: "gameModePartyDescription",
                icon: CustomIcons.game_mode_party,
                players: widget.players,
                enabledGames: [
                  GameType.DARE,
                  GameType.TRUTH,
                  GameType.CHALLENGES,
                  GameType.NEVER_HAVE_I_EVER,
                  GameType.OPINION,
                  GameType.WHO_WOULD_RATHER
                ],
              ),
              Divider(),
              GameSelectTile(
                enabled: gameState == CurrentGameState.STOPPED,
                backgroundColors: [
                  Color.fromRGBO(79, 44, 208, 1),
                  Color.fromRGBO(7, 149, 199, 1),
                ],
                parentContext: context,
                onGameStateChange: onStateChange,
                title: "gameModeQuiz",
                subtitle: "gameModeQuizDescription",
                icon: CustomIcons.game_mode_quiz,
                players: widget.players,
                enabledGames: [
                  GameType.QUIZ,
                  GameType.GUESS,
                ],
              ),
              Divider(),
              GameSelectTile(
                enabled: gameState == CurrentGameState.STOPPED,
                backgroundColors: [
                  Color.fromRGBO(25, 96, 2, 1),
                  Color.fromRGBO(95, 154, 0, 1),
                ],
                parentContext: context,
                onGameStateChange: onStateChange,
                title: "gameModeSongGuess",
                subtitle: "gameModeSongGuessDescription",
                icon: CustomIcons.game_mode_song,
                players: widget.players,
                enabledGames: [
                  GameType.GUESS_THE_SONG,
                ],
              ),
              Divider(),
              Builder(builder: (BuildContext context) {
                bool purchased = purchaseState == PurchaseState.DONE;
                return GestureDetector(
                  onTap: !purchased ? purchase : null,
                  child: AbsorbPointer(
                    absorbing: !purchased,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity: purchased ? 1 : .5,
                          duration: Duration(milliseconds: 500),
                          child: CustomGameSelectTile(
                            title: "gameModeCustom",
                            subtitle: "gameModeCustomDescription",
                            icon: CustomIcons.game_mode_custom,
                            players: widget.players,
                            enabledGames: enabledGamesCustom,
                            backgroundColors: [
                              Color.fromRGBO(131, 58, 180, 1),
                              Color.fromRGBO(253, 29, 29, 1),
                              Color.fromRGBO(253, 187, 45, 1),
                            ],
                            parentContext: context,
                            onGameStateChange: onStateChange,
                            enabled: gameState == CurrentGameState.STOPPED,
                          ),
                        ),
                        purchased
                            ? Container()
                            : Positioned(
                                top: 12,
                                right: 12,
                                child: Icon(
                                  Icons.lock_outline,
                                  color: Colors.white,
                                ),
                              ),
                        purchaseState == PurchaseState.IN_PROGRESS
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              )
                            : Container()
                      ],
                    ),
                  ),
                );
              }),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}

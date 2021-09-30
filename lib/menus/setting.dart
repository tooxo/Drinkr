import 'dart:async';
import 'dart:ui';

import 'package:drinkr/menus/licenses.dart';
import 'package:drinkr/utils/ad.dart';
import 'package:drinkr/utils/custom_icons.dart';
import 'package:drinkr/utils/file.dart';
import 'package:drinkr/utils/purchases.dart';
import 'package:drinkr/utils/spotify_api.dart';
import 'package:drinkr/utils/spotify_storage.dart';
import 'package:drinkr/utils/types.dart';
import 'package:drinkr/widgets/buy_premium.dart';
import 'package:drinkr/widgets/custom_radio.dart';
import 'package:drinkr/widgets/extending_textfield_button.dart';
import 'package:drinkr/widgets/gradient.dart';
import 'package:drinkr/widgets/icon_list_tile.dart';
import 'package:drinkr/widgets/spotify_tile.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

import 'game_mode.dart';

class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  static const String SETTING_INCLUSION_OF_QUESTIONS =
      "SETTING_INCLUSION_OF_QUESTIONS";

  static const int ONLY_INCLUDED = 0;
  static const int BOTH = 1;
  static const int ONLY_CUSTOM = 2;

  bool spotifyEdit = false;
  ExpandableController spotifyController = ExpandableController();

  void onPlaylistChange(Playlist playlist) async {
    await SpotifyStorage.playlists_box.put(playlist.id, playlist);
    setState(() {});
  }

  void onPlaylistDelete(Playlist playlist) async {
    await SpotifyStorage.playlists_box.delete(playlist.id);
    setState(() {});
  }

  ButtonState adButtonState = ButtonState.idle;

  void onAdButtonStateChange(ButtonState newState) {
    setState(() {
      adButtonState = newState;
    });
  }

  late StreamSubscription<BoxEvent> playlistSubscription;

  PurchaseState purchaseState = PurchaseState.AVAILABLE;

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          purchaseState = PurchaseState.IN_PROGRESS;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
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

  @override
  void initState() {
    super.initState();
    playlistSubscription = SpotifyStorage.playlists_box.watch().listen(
      (BoxEvent event) {
        setState(() {});
      },
    );

    InAppPurchase.instance.purchaseStream
        .listen((List<PurchaseDetails> purchaseDetails) {
      _listenToPurchaseUpdated(purchaseDetails);
    });

    Purchases.isPremiumPurchased().then(
      (bool value) => {
        setState(
          () {
            if (purchaseState == PurchaseState.AVAILABLE && value) {
              purchaseState = PurchaseState.DONE;
            }
          },
        )
      },
    );
  }

  @override
  void dispose() {
    playlistSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        title: Text(
          "settings",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ).tr(),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: BuyPremium(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ColorGradient(
                  colors: [
                    Color.fromRGBO(36, 140, 0, 1),
                    Color.fromRGBO(36, 140, 0, 1),
                  ],
                  roundness: 15,
                  child: ExpandablePanel(
                    controller: spotifyController,
                    theme: ExpandableThemeData(
                      hasIcon: false,
                      useInkWell: false,
                    ),
                    header: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16,
                      ),
                      child: IconListTile(
                        iconData: CustomIcons.spotify_outline,
                        title: "spotifyPlaylists".tr(),
                        subtitle: "spotifyPlaylistsDescription".tr(),
                        onTap: () {},
                        // iconSize: 55,
                      ),
                    ),
                    collapsed: GestureDetector(
                      onTap: () {
                        spotifyController.toggle();
                      },
                      child: Center(
                        child: Container(
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    expanded: Column(
                      children: [
                        Divider(
                          color: Colors.white,
                          thickness: 1,
                          height: 1,
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 350,
                          ),
                          child: Container(
                            color: Color.fromRGBO(36, 140, 0, 1),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: FutureBuilder<List<String>>(
                                  future: getIncludedFiles(
                                    GameType.GUESS_THE_SONG,
                                    context,
                                    false,
                                  ),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<String>> snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container();
                                    }
                                    List<String> ids = snapshot.data!
                                        .map((e) => Spotify.getIdFromUrl(e)!)
                                        .toList();
                                    List<Playlist> playlists =
                                        SpotifyStorage.playlists_box.values
                                            .where(
                                              (element) =>
                                                  !element.included ||
                                                  ids.contains(element.id),
                                            )
                                            .toList()
                                          ..sort();
                                    return Column(
                                      children: [
                                        for (Playlist p in playlists)
                                          SpotifyTile(
                                            p,
                                            onChanged: onPlaylistChange,
                                            onDelete: onPlaylistDelete,
                                            expanded: spotifyEdit,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.white,
                          thickness: 1,
                          height: 1,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ExtendingTextFieldButton(
                                () {
                                  setState(() {
                                    spotifyEdit = !spotifyEdit;
                                  });
                                },
                                this.spotifyEdit,
                                (Playlist playlist) async {
                                  await SpotifyStorage.playlists_box
                                      .put(playlist.id, playlist);
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            spotifyController.toggle();
                          },
                          child: Center(
                            child: Icon(
                              Icons.arrow_drop_up_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ColorGradient(
                  roundness: 15,
                  colors: [
                    Color.fromRGBO(0xFF, 0x6B, 0x00, 1),
                    Color.fromRGBO(0xFF, 0x6B, 0x00, 1),
                  ],
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                      hasIcon: false,
                    ),
                    header: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16,
                      ),
                      child: IconListTile(
                        title: "deactivateAds".tr(),
                        subtitle: "deactivateAdsDescription".tr(),
                        iconData: CustomIcons.no_ad,
                        // iconSize: 55,
                        onTap: () {},
                      ),
                    ),
                    collapsed: Center(
                      child: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.white,
                      ),
                    ),
                    expanded: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: ProgressButton.icon(
                            onPressed: () => showInterstitialAd(
                                context, onAdButtonStateChange),
                            state: adButtonState,
                            textStyle: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                            iconedButtons: {
                              ButtonState.idle: IconedButton(
                                color: Colors.black.withOpacity(.4),
                                disabledColor: Colors.black.withOpacity(.2),
                                text: "startGame".tr(),
                                icon: Icon(
                                  Icons.ondemand_video_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              ButtonState.fail: IconedButton(
                                color: Colors.redAccent,
                              ),
                              ButtonState.loading: IconedButton(
                                color: Colors.black.withOpacity(.4),
                              ),
                              ButtonState.success: IconedButton(
                                color: Colors.green,
                              )
                            },
                          ),
                        ),
                        FutureBuilder<bool>(
                            future: shouldShowAds(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData || snapshot.data) {
                                return Text(
                                  "deactivateAdsText".tr(),
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }
                              return Center(
                                child: Text(
                                  "adsAlreadyDisabled".tr(),
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }),
                        Icon(
                          Icons.arrow_drop_up_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ColorGradient(
                  roundness: 15,
                  colors: [
                    Color.fromRGBO(0xFF, 0x6B, 0x00, 1),
                    Color.fromRGBO(0xFF, 0x6B, 0x00, 1),
                  ],
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                      hasIcon: false,
                    ),
                    header: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16,
                      ),
                      child: IconListTile(
                        title: "language".tr(),
                        subtitle: "languageSubtitle".tr(),
                        iconData: CustomIcons.translation,
                        onTap: () {},
                      ),
                    ),
                    collapsed: Center(
                      child: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.white,
                      ),
                    ),
                    expanded: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          child: Column(
                            children: [
                              for (Locale locale in context.supportedLocales)
                                GestureDetector(
                                  onTap: () async {
                                    await EasyLocalization.of(context)!
                                        .setLocale(locale);
                                    unawaited(SpotifyStorage
                                        .initializePreshippedPlaylists(
                                            context));
                                    setState(() {});
                                  },
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      LocaleNamesLocalizationsDelegate
                                          .nativeLocaleNames[locale.toString()]!
                                          .split(" ")
                                          .first,
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 23),
                                    ),
                                    trailing: CustomRadioWidget(
                                      enabled: true,
                                      groupValue: context.locale,
                                      value: locale,
                                      onChanged: (Locale value) async {
                                        await EasyLocalization.of(context)!
                                            .setLocale(locale);
                                        unawaited(SpotifyStorage
                                            .initializePreshippedPlaylists(
                                                context));
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_up_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ColorGradient(
                  roundness: 15,
                  colors: [
                    Color.fromRGBO(0xFF, 0x6B, 0x00, 1),
                    Color.fromRGBO(0xFF, 0x6B, 0x00, 1),
                  ],
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                      hasIcon: false,
                    ),
                    header: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16,
                      ),
                      child: IconListTile(
                        title: "restorePurchases".tr(),
                        subtitle: "restorePurchasesDescription".tr(),
                        iconData: CustomIcons.refresh,
                        onTap: () {},
                      ),
                    ),
                    collapsed: Center(
                      child: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.white,
                      ),
                    ),
                    expanded: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: () async {
                                    await InAppPurchase.instance
                                        .restorePurchases();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8),
                                    child: Text(
                                      "restore",
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ).tr(),
                                  ),
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.black.withOpacity(.4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_up_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ColorGradient(
                  roundness: 15,
                  colors: [
                    Color.fromRGBO(0xFF, 0x6B, 0x00, 1),
                    Color.fromRGBO(0xFF, 0x6B, 0x00, 1),
                  ],
                  child: ExpandablePanel(
                    theme: ExpandableThemeData(
                      hasIcon: false,
                    ),
                    header: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16,
                      ),
                      child: IconListTile(
                        title: "about".tr(),
                        subtitle: "licensesDescription".tr(),
                        iconData: Icons.info_outline,
                        onTap: () {},
                      ),
                    ),
                    collapsed: Center(
                      child: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.white,
                      ),
                    ),
                    expanded: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Divider(
                            color: Colors.white,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return Licenses();
                                  },
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8),
                              child: Text(
                                "licenses",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ).tr(),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_up_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:drinkr/main.dart';
import 'package:drinkr/utils/purchases.dart';
import 'package:drinkr/widgets/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pedantic/pedantic.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

const String ADS_SETTING = "SHOULD_SHOW_ADS_SETTINGS";
const String ADS_SETTINGS_PERMANENT = "DEACTIVATE_ADS_PERMANENTLY";
const String AD_DIALOG_SETTING = "SHOULD_SHOW_AD_DIALOG_SETTING";
const String LAST_AD_DISPLAY = "LAST_TIME_AD_WAS_DISPLAYED_STORE";

Future<bool> shouldShowAds() async {
  if (!ADS_ENABLED) return false;
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int lastMillisSinceEpoch = (preferences.getInt(ADS_SETTING) != null
      ? preferences.getInt(ADS_SETTING)
      : 0)!;
  DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastMillisSinceEpoch);
  DateTime nowDate = DateTime.now();

  return nowDate.difference(lastDate).inMinutes > 60;
}

Future<bool> shouldShowAdDialog() async {
  if (!ADS_ENABLED) return false;
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (await Purchases.isPremiumPurchased()) {
    return false;
  }
  if (preferences.getBool(AD_DIALOG_SETTING) ?? true) {
    DateTime millisSinceLastShow = DateTime.fromMillisecondsSinceEpoch(
        preferences.getInt(LAST_AD_DISPLAY) ?? 0);
    DateTime currentTime = DateTime.now();
    if (currentTime.difference(millisSinceLastShow) > Duration(days: 1)) {
      return true;
    }
  }
  return false;
}

void checkAdVariables() {
  if (!const bool.fromEnvironment("ADS_ENABLED", defaultValue: false)) return;

  String banner =
      const String.fromEnvironment("BANNER_AD_ID", defaultValue: "");
  if (banner == "" || banner == BannerAd.testAdUnitId) {
    print("WARN: Invalid Banner Ad Id: $banner");
  }

  String rewarded =
      const String.fromEnvironment("REWARDED_AD_ID", defaultValue: "");
  if (rewarded == "" || rewarded == RewardedAd.testAdUnitId) {
    print("WARN: Invalid Rewarded Ad Id: $rewarded");
  }

  String fullscreen =
      const String.fromEnvironment("INTERSTITIAL_AD_ID", defaultValue: "");
  if (fullscreen == "" || fullscreen == InterstitialAd.testAdUnitId) {
    print("WARN: Invalid Fullscreen Ad Id: $fullscreen");
  }
}

void showAdDialog(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green.shade600,
          title: Text(
            "mainAdDialogTitle",
            style: GoogleFonts.nunito(
              textStyle: TextStyle(color: Colors.white),
              fontWeight: FontWeight.w800,
              fontSize: 30,
            ),
          ).tr(),
          content: Text(
            "mainAdDialogDescription",
            style: GoogleFonts.nunito(
              textStyle: TextStyle(color: Colors.white),
              fontSize: 25,
            ),
          ).tr(),
          actions: <Widget>[
            TextButton(
              child: Text(
                "ok",
                style: GoogleFonts.caveatBrush(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ).tr(),
              onPressed: () {
                showInterstitialAd(context, (_) {});
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text(
                "notAgain",
                style: GoogleFonts.caveatBrush(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ).tr(),
              onPressed: () async {
                await (await SharedPreferences.getInstance())
                    .setBool(AD_DIALOG_SETTING, false);
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      });
}

Future<void> deactivateAds() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setInt(ADS_SETTING, DateTime.now().millisecondsSinceEpoch);
}

Future<void> showInterstitialAd(
  BuildContext buildContext,
  ValueChanged<ButtonState> valueChanged,
) async {
  if (!ADS_ENABLED) return;

  valueChanged(ButtonState.loading);

  RewardedAd? ad;
  bool rewarded = false;

  OnUserEarnedRewardCallback onUserEarnedRewardCallback = (
    RewardedAd ad,
    RewardItem rewardItem,
  ) =>
      rewarded = true;

  RewardedAdLoadCallback rewardedAdLoadCallback =
      RewardedAdLoadCallback(onAdLoaded: (RewardedAd rewardedAd) async {
    ad = rewardedAd;

    if (ad != null) {
      ad!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) async {
          print("dismissed. Ad finished?: ${rewarded.toString()}");
          unawaited(ad.dispose());

          if (rewarded) {
            await deactivateAds();
            valueChanged(ButtonState.success);
            await showDialog(
                context: buildContext,
                builder: (BuildContext context) => CustomAlert(
                      titleTranslationKey: "adSuccessTitle",
                      textTranslationKey: "adSuccessDescription",
                      backgroundColor: Colors.green.shade700,
                      textColor: Colors.white,
                      buttonTextTranslationKey: "close",
                    ));
            valueChanged(ButtonState.idle);
          } else {
            valueChanged(ButtonState.fail);
            await showDialog(
              context: buildContext,
              builder: (BuildContext context) => CustomAlert(
                titleTranslationKey: "error",
                textTranslationKey: "adVideoAbortDescription",
                backgroundColor: Colors.deepOrange,
                textColor: Colors.white,
                buttonTextTranslationKey: "close",
              ),
            );
            valueChanged(ButtonState.idle);
          }
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          print("Ad failed to show: ${error.toString()}");
          ad.dispose();
          valueChanged(ButtonState.fail);
        },
      );

      await ad!.show(
        onUserEarnedReward: onUserEarnedRewardCallback,
      );
    }
  }, onAdFailedToLoad: (LoadAdError loadAdError) async {
    print("failed to load: ${loadAdError.toString()}");
    valueChanged(ButtonState.fail);

    await showDialog(
      context: buildContext,
      builder: (BuildContext context) => CustomAlert(
        titleTranslationKey: "adsNoVideosTitle",
        textTranslationKey: "adsNoVideosDescription",
        backgroundColor: Colors.deepOrange,
        textColor: Colors.white,
        buttonTextTranslationKey: "close",
      ),
    );

    valueChanged(ButtonState.idle);
  });

  const String adId =
      String.fromEnvironment("REWARDED_AD_ID", defaultValue: "");

  await RewardedAd.load(
    adUnitId: adId == "" ? RewardedAd.testAdUnitId : adId,
    rewardedAdLoadCallback: rewardedAdLoadCallback,
    request: AdRequest(),
  );
}

Future<void> showFullscreenAd(
  BuildContext buildContext,
) async {
  if (!(await shouldShowAds())) {
    return;
  }

  InterstitialAd? interstitial;
  const String adId =
      String.fromEnvironment("INTERSTITIAL_AD_ID", defaultValue: "");

  return await InterstitialAd.load(
    adUnitId: adId == "" ? InterstitialAd.testAdUnitId : adId,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdFailedToLoad: (LoadAdError error) {
        print(error.message);
      },
      onAdLoaded: (InterstitialAd ad) {
        interstitial = ad;

        interstitial!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
            ad.dispose();
          },
        );
        interstitial!.show();
      },
    ),
  );
}

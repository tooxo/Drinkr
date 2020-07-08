import 'package:SaufApp/main.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

const String ADS_SETTING = "SHOULD_SHOW_ADS_SETTINGS";
const String ADS_SETTINGS_PERMANENT = "DEACTIVATE_ADS_PERMANENTLY";

Future<bool> shouldShowAds() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int lastMillisSinceEpoch = preferences.getInt(ADS_SETTING) != null
      ? preferences.getInt(ADS_SETTING)
      : 0;
  DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastMillisSinceEpoch);
  DateTime nowDate = DateTime.now();

  return nowDate.difference(lastDate).inMinutes > 60 || !ADS_ENABLED_BUQF1EVY;
}

Future<void> deactivateAds() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setInt(ADS_SETTING, DateTime.now().millisecondsSinceEpoch);
}

Future<void> showInterstitialAd(BuildContext buildContext) async {
  if (!ADS_ENABLED_BUQF1EVY) return;
  await RewardedVideoAd.instance.load(
      adUnitId: RewardedVideoAd.testAdUnitId,
      targetingInfo: MobileAdTargetingInfo());

  bool rewarded = false;

  RewardedVideoAd.instance.listener =
      (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
    if (event == RewardedVideoAdEvent.rewarded) {
      rewarded = true;
      deactivateAds();
      showDialog(
          context: buildContext,
          builder: (BuildContext context) {
            return new AlertDialog(
              backgroundColor: Colors.green.shade700,
              title: Text("adSuccessTitle",
                  style: GoogleFonts.caveatBrush(
                    textStyle: TextStyle(color: Colors.black),
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  )).tr(),
              content: Text(
                "adSuccessDescription",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(color: Colors.black),
                  fontSize: 25,
                ),
              ).tr(),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: new Text(
                    "close",
                    style: GoogleFonts.caveatBrush(
                        color: Colors.black, fontSize: 20),
                  ).tr(),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          });
    }
    if (event == RewardedVideoAdEvent.closed) {
      if (!rewarded) {
        showDialog(
          context: buildContext,
          builder: (BuildContext context) {
            return new AlertDialog(
              backgroundColor: Colors.deepOrange,
              title: Text(
                "error",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(color: Colors.black),
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                ),
              ).tr(),
              content: Text(
                "adVideoAbortDescription",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(color: Colors.black),
                  fontSize: 25,
                ),
              ).tr(),
              actions: <Widget>[
                FlatButton(
                  child: new Text(
                    "close",
                    style: GoogleFonts.caveatBrush(
                        color: Colors.black, fontSize: 20),
                  ).tr(),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      }
    }
  };

  try {
    await RewardedVideoAd.instance.show();
  } catch (platformException) {
    await RewardedVideoAd.instance.load(
        adUnitId: RewardedVideoAd.testAdUnitId,
        targetingInfo: MobileAdTargetingInfo());
    try {
      await RewardedVideoAd.instance.show();
    } catch (platformException) {
      showDialog(
        context: buildContext,
        builder: (BuildContext context) {
          return new AlertDialog(
            backgroundColor: Colors.deepOrange,
            title: Text("adsNoVideosTitle",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(color: Colors.black),
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                )).tr(),
            content: Text(
              "adsNoVideosDescription",
              style: GoogleFonts.caveatBrush(
                textStyle: TextStyle(color: Colors.black),
                fontSize: 25,
              ),
            ).tr(),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text(
                  "close",
                  style: GoogleFonts.caveatBrush(
                      color: Colors.black, fontSize: 20),
                ).tr(),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );
    }
  }
}

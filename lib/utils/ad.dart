import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String ADS_SETTING = "SHOULD_SHOW_ADS_SETTINGS";
const String ADS_SETTINGS_PERMANENT = "DEACTIVATE_ADS_PERMANENTLY";

Future<bool> shouldShowAds() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int lastMillisSinceEpoch = preferences.getInt(ADS_SETTING) != null
      ? preferences.getInt(ADS_SETTING)
      : 0;
  DateTime lastDate = DateTime.fromMillisecondsSinceEpoch(lastMillisSinceEpoch);
  DateTime nowDate = DateTime.now();

  if (nowDate.difference(lastDate).inMinutes < 60) {
    return false;
  }
  return true;
}

Future<void> deactivateAds() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setInt(ADS_SETTING, DateTime.now().millisecondsSinceEpoch);
}

class NoAdLoadedException implements Exception {}

Future<void> showInterstitialAd(BuildContext buildContext) async {
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
              title: Text("Werbung deaktiviert",
                  style: GoogleFonts.caveatBrush(
                    textStyle: TextStyle(color: Colors.black),
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  )),
              content: Text(
                "Du kannst die nächste Stunde in der App werbefrei verbringen.\nVielen Dank bro.",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(color: Colors.black),
                  fontSize: 25,
                ),
              ),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                FlatButton(
                  child: new Text(
                    "Schließen",
                    style: GoogleFonts.caveatBrush(
                        color: Colors.black, fontSize: 20),
                  ),
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
              title: Text("Fehler",
                  style: GoogleFonts.caveatBrush(
                    textStyle: TextStyle(color: Colors.black),
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  )),
              content: Text(
                "Du musst das Video bis zum Ende anschauen! Nix da überspringen!",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(color: Colors.black),
                  fontSize: 25,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: new Text(
                    "Schließen",
                    style: GoogleFonts.caveatBrush(
                        color: Colors.black, fontSize: 20),
                  ),
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
            title: Text("Keine Videos mehr :(",
                style: GoogleFonts.caveatBrush(
                  textStyle: TextStyle(color: Colors.black),
                  fontWeight: FontWeight.w800,
                  fontSize: 30,
                )),
            content: Text(
              "Momentan sind keine Videos mehr verfügbar. Versuch es später nochmal.",
              style: GoogleFonts.caveatBrush(
                textStyle: TextStyle(color: Colors.black),
                fontSize: 25,
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text(
                  "Schließen",
                  style: GoogleFonts.caveatBrush(
                      color: Colors.black, fontSize: 20),
                ),
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

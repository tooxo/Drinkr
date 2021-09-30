import 'dart:ui';

import 'package:drinkr/utils/custom_icons.dart';
import 'package:drinkr/utils/purchases.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

import 'gradient.dart';
import 'icon_list_tile.dart';

class ExpandedController extends ExpandableController {}

class BuyPremium extends StatelessWidget {
  final bool modal;

  BuyPremium({this.modal = false}) {
    expandableController = ExpandableController(initialExpanded: modal);
  }

  late final ExpandableController expandableController;

  Widget buildListTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
        title: Text(
          text,
          style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ).tr(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColorGradient(
      roundness: 15,
      colors: [
        Color.fromRGBO(131, 58, 180, 1),
        Color.fromRGBO(253, 29, 29, 1),
        Color.fromRGBO(253, 187, 45, 1),
      ],
      child: ExpandablePanel(
        controller: expandableController,
        theme: ExpandableThemeData(
          hasIcon: false,
          tapHeaderToExpand: !modal,
          tapBodyToExpand: !modal,
        ),
        header: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 16,
          ),
          child: IconListTile(
            title: "buyPremium".tr(),
            subtitle: "buyPremiumDescription".tr(),
            iconData: CustomIcons.gameModeCustom,
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
            buildListTile(CustomIcons.noAd, "premiumDisableAds"),
            buildListTile(CustomIcons.gameModeSong, "premiumAddPlaylists"),
            buildListTile(CustomIcons.gameModeCustom, "premiumCustom"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Divider(
                color: Colors.white,
                thickness: 1,
              ),
            ),
            Padding(
              padding: modal
                  ? const EdgeInsets.only(top: 8.0)
                  : const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
              child: ProgressButton.icon(
                onPressed: modal
                    ? () async {
                        bool simpleSuccess = await Purchases.purchasePremium();
                        if (simpleSuccess) Navigator.of(context).pop();
                      }
                    : Purchases.purchasePremium,
                state: ButtonState.idle,
                textStyle: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                iconedButtons: {
                  ButtonState.idle: IconedButton(
                    color: Colors.black.withOpacity(.4),
                    disabledColor: Colors.black.withOpacity(.2),
                    text: "buy".tr(),
                    icon: Icon(
                      Icons.monetization_on_outlined,
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
            modal
                ? Container()
                : Icon(
                    Icons.arrow_drop_up_rounded,
                    color: Colors.white,
                  ),
          ],
        ),
      ),
    );
  }
}

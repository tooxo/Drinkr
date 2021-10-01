import 'package:drinkr/menus/game_mode.dart';
import 'package:drinkr/utils/purchases.dart';
import 'package:flutter/material.dart';

class Purchasable extends StatelessWidget {
  final Widget child;

  Purchasable({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    bool purchased = Purchases.purchaseState == PurchaseState.done;
    return GestureDetector(
      onTap: !purchased ? () => Purchases.openPremiumMenu(context) : null,
      child: AbsorbPointer(
        absorbing: !purchased,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: purchased ? 1 : .5,
              duration: Duration(milliseconds: 500),
              child: child,
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
            Purchases.purchaseState == PurchaseState.inProgress
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
  }
}

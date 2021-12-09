import 'package:drinkr/menus/game_mode.dart';
import 'package:drinkr/utils/purchases.dart';
import 'package:flutter/material.dart';

class Purchasable extends StatelessWidget {
  final Widget child;
  final bool showLock;
  final Alignment alignment;

  Purchasable({
    required this.child,
    this.showLock = true,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    bool purchased = Purchases.purchaseState == PurchaseState.done;
    return GestureDetector(
      onTap: !purchased ? () => Purchases.openPremiumMenu(context) : null,
      child: AbsorbPointer(
        absorbing: !purchased,
        child: Stack(
          alignment: alignment,
          children: [
            AnimatedOpacity(
              opacity: purchased ? 1 : .5,
              duration: Duration(milliseconds: 500),
              child: child,
            ),
            purchased || !showLock
                ? Container()
                : Positioned(
                    top: 12,
                    right: 12,
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.white.withOpacity(.8),
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

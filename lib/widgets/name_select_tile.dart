import 'package:drinkr/utils/custom_icons.dart';
import 'package:drinkr/utils/player.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class NameSelectTile extends StatefulWidget {
  final Player? player;
  final Function() onDelete;
  final Function(String) onNameChange;
  final Function(String) onPlayerAdd;
  final FocusNode? focusNode;

  NameSelectTile({
    required this.player,
    required this.onDelete,
    required this.onNameChange,
    required this.onPlayerAdd,
    this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NameSelectTileState();
}

class _NameSelectTileState extends State<NameSelectTile> {
  late TextEditingController controller;
  late FocusNode focusNode;

  @override
  void initState() {
    controller = TextEditingController(text: widget.player?.name);
    focusNode = widget.focusNode ?? FocusNode();
    focusNode.addListener(
      () {
        if (focused && !focusNode.hasFocus) {
          // lost focus
          onCompletion(controller.text);
        }
        focused = focusNode.hasFocus;
        if (mounted) {
          setState(() {});
        }
      },
    );
    super.initState();
  }

  void onCompletion(String sub) {
    if (widget.player == null) {
      if (sub.trim() != "") {
        controller.clear();
        print("player added");
        widget.onPlayerAdd(sub.trim());
      }
    } else {
      if (sub.trim() == "") {
        widget.onDelete();
      } else {
        widget.onNameChange(sub);
      }
    }
  }

  void onSubmit(String sub) {
    onCompletion(sub);
    if (widget.player == null) {}
  }

  void onNameChange(String newName) {
    if (widget.player != null) {
      // widget.onNameChange(newName);
    }
  }

  void onNameChangeCompleted(String newName) {}

  @override
  void dispose() {
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool focused = false;

  Widget buildInnerAdd() {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () {
        focused = true;
        focusNode.requestFocus();
        setState(() {});
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildInner(BuildContext context) {
    if (widget.player == null && !focused) {
      return buildInnerAdd();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              textInputAction: widget.player != null
                  ? TextInputAction.done
                  : TextInputAction.next,
              onChanged: onNameChange,
              onSubmitted: onSubmit,
              onEditingComplete: widget.player != null ? null : () {},
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                counterText: "",
                isDense: true,
              ),
              maxLines: 1,
              maxLength: 16,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          !this.focused
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                  ),
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Icon(
                      CustomIcons.trash,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            30,
          ),
        ),
        elevation: 0,
        child: AnimatedContainer(
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(30),
              color: focused
                  ? Colors.white.withOpacity(.3)
                  : Colors.white.withOpacity(.15),
            ),
            duration: Duration(
              milliseconds: 300,
            ),
            child: buildInner(context)),
      ),
    );
  }
}

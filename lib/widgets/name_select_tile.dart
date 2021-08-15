import 'package:drinkr/utils/player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';


class NameSelectTile extends StatefulWidget {
  final Player player;
  final Function() onDelete;
  final Function(String) onNameChange;

  NameSelectTile({
    required this.player,
    required this.onDelete,
    required this.onNameChange,
  });

  @override
  State<StatefulWidget> createState() => _NameSelectTileState();
}

class _NameSelectTileState extends State<NameSelectTile> {
  late TextEditingController controller;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    controller = TextEditingController(text: widget.player.name);
    focusNode.addListener(
      () {
        if (focused && !focusNode.hasFocus) {
          // lost focus
          onSubmit(controller.text);
        }
        focused = focusNode.hasFocus;
        setState(() {});
      },
    );
    super.initState();
  }

  void onSubmit(String sub) {
    if (sub.trim() == "") {
      widget.onDelete();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  bool focused = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 0,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: focused
              ? Colors.white.withOpacity(.3)
              : Colors.white.withOpacity(.15),
        ),
        duration: Duration(
          milliseconds: 300,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  controller: controller,
                  onChanged: widget.onNameChange,
                  onSubmitted: onSubmit,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    counterText: "",
                  ),
                  maxLines: 1,
                  maxLength: 16,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  style: GoogleFonts.nunito(color: Colors.white),
                ),
              ),
              !this.focused
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          height: 30,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

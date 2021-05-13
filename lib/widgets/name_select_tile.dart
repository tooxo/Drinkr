import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NameSelectTile extends StatelessWidget {
  final String playerName;
  final int playerId;
  final dynamic deleteFunc;
  final dynamic changeFunc;

  late final TextEditingController textEditingController;

  NameSelectTile(
      {Key? key,
      required this.playerName,
      required this.playerId,
      this.deleteFunc,
      this.changeFunc}) {
    this.textEditingController = TextEditingController(
      text: this.playerName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Color.fromRGBO(255, 92, 0, 1),
          width: 3,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: 10,
        ),
        title: TextField(
          controller: TextEditingController.fromValue(TextEditingValue(
              text: playerName,
              selection: TextSelection.collapsed(offset: playerName.length))),
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          ),
          onChanged: (String newValue) => this.changeFunc(playerId, newValue),
        ),
        /*title: Text(
          this.playerName,
          maxLines: 1,
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 20),
        ),*/
        trailing: IconButton(
          onPressed: this.deleteFunc,
          padding: EdgeInsets.all(0),
          icon: Icon(
            Icons.highlight_off_outlined,
            color: Color.fromRGBO(255, 92, 0, 1),
            size: 35,
          ),
        ),
      ),
    );
  }
}

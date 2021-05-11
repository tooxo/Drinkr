import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NameSelectTile extends StatelessWidget {
  final String playerName;
  final dynamic deleteFunc;

  const NameSelectTile({Key key, this.playerName, this.deleteFunc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color.fromRGBO(255, 92, 0, 1),
              width: 3,
            )),
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  playerName,
                  maxLines: 1,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: deleteFunc,
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    Icons.highlight_off_outlined,
                    size: 35,
                    color: Color.fromRGBO(255, 92, 0, 1),                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Sprache extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 111, 0, 1),
      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        centerTitle: true,
        title: Text(
          "Sprache",
          style: GoogleFonts.caveatBrush(
            color: Colors.black,
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {},
                  child: Text(
                    'English',
                    style: GoogleFonts.caveatBrush(
                      textStyle: TextStyle(color: Colors.black, fontSize: 45),
                    ),
                  ),
                  //Todo: on pressed - > Deutsch
                ),
                Image(
                  image: NetworkImage(
                      "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Flag_of_Great_Britain_%281707%E2%80%931800%29.svg/1000px-Flag_of_Great_Britain_%281707%E2%80%931800%29.svg.png"),
                  width: 100,
                  height: 50,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {},
                  child: Text(
                    'Deutsch',
                    style: GoogleFonts.caveatBrush(
                      textStyle: TextStyle(color: Colors.black, fontSize: 45),
                    ),
                  ),
                  //Todo: on pressed - > englisch
                ),
                Image(
                  image: NetworkImage(
                      "https://cdn.webshopapp.com/shops/94414/files/52383360/flagge-von-deutschland.jpg"),
                  width: 100,
                  height: 50,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {},
                  child: Text(
                    'Español',
                    style: GoogleFonts.caveatBrush(
                      textStyle: TextStyle(color: Colors.black, fontSize: 45),
                    ),
                  ),
                  //Todo: on pressed - > spanisch
                ),
                Image(
                  image: NetworkImage(
                      "https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Flag_of_Spain.svg/1200px-Flag_of_Spain.svg.png"),
                  width: 100,
                  height: 50,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {},
                  child: Text('Français',
                      style: GoogleFonts.caveatBrush(
                        textStyle: TextStyle(color: Colors.black, fontSize: 45),
                      )),
                  //Todo: on pressed - > Deutsch
                ),
                Image(
                  image: NetworkImage(
                      "https://cdn.countryflags.com/thumbs/france/flag-800.png"),
                  width: 100,
                  height: 50,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {},
                  child: Text(
                    'Türk',
                    style: GoogleFonts.caveatBrush(
                      textStyle: TextStyle(color: Colors.black, fontSize: 45),
                    ),
                  ),
                  //Todo: on pressed - > Deutsch
                ),
                Image(
                  image: NetworkImage(
                      "https://cdn.webshopapp.com/shops/94414/files/52434394/flag-of-turkey.jpg"),
                  width: 100,
                  height: 50,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: () {},
                  child: Text(
                    'русский',
                    style: GoogleFonts.caveatBrush(
                      textStyle: TextStyle(color: Colors.black, fontSize: 45),
                    ),
                  ),
                  //Todo: on pressed - > Deutsch
                ),
                Image(
                  image: NetworkImage(
                      "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Flag_of_Russia_with_border.svg/900px-Flag_of_Russia_with_border.svg.png"),
                  width: 100,
                  height: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

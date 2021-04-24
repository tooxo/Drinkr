import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class Licenses extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LicensesState();
}

class LicensesState extends State<Licenses> {
  List<List<String>> items = [];
  Map<String, List<List<String>>> itemMap = Map<String, List<List<String>>>();

  void populateItems() async {
    await LicenseRegistry.licenses.forEach((license) {
      List<String> appendable = [];
      appendable.add(license.packages.join(", "));
      for (String package in license.packages) {
        if (!itemMap.containsKey(package)) {
          itemMap[package] = [];
        }
        itemMap[package].add(
            license.paragraphs.map((paragraph) => paragraph.text).toList());
      }
    });

    itemMap.keys.map((e) => e = e.toLowerCase());

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    populateItems();
  }

  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 21, 21, 1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(21, 21, 21, 1),
        title: Text(
          "Über uns/Lizensen",
          style: GoogleFonts.nunito(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ).tr(),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 400,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                            flex: 3,
                            child: Image.asset("assets/image/cutebeer.png")),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Drinkr",
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600),
                                ),
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Created by ',
                                      style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w600),
                                      /*defining default style is optional */
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: "Artjom Zakoyan",
                                          style: GoogleFonts.nunito(
                                              color: Colors.deepOrange,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        TextSpan(
                                          text: ' and ',
                                          style: GoogleFonts.nunito(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        TextSpan(
                                          text: "Till Schulte",
                                          style: GoogleFonts.nunito(
                                              color: Colors.deepOrange,
                                              fontSize: 30,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      const url =
                                          "https://github.com/tooxo/DrinkrFlutter";
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      }
                                    },
                                    icon: Icon(
                                      const IconData(0xe802,
                                          fontFamily: "Icons",
                                          fontPackage: null),
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "GitHub",
                                      style: GoogleFonts.nunito(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  "Licenses",
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                itemMap.isEmpty
                    ? SpinKitFadingCircle(
                        color: Colors.white,
                      )
                    : Container(),
                for (String package in itemMap.keys.toList()
                  ..sort((i, j) {
                    return i.toLowerCase().compareTo(j.toLowerCase());
                  }))
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Theme(
                          data: ThemeData(
                              textTheme: TextTheme(
                                  subtitle1: TextStyle(color: Colors.white)),
                              accentColor: Colors.white),
                          child: ExpansionTile(
                            title: Text(
                              package,
                              style: TextStyle(color: Colors.white),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, bottom: 16.0),
                                child: Column(
                                  children: <Widget>[
                                    for (List<String> version
                                        in itemMap[package])
                                      ExpansionTile(
                                        title: Text(
                                            version[0].length > 50
                                                ? version[0].substring(0, 50) +
                                                    "..."
                                                : version[0],
                                            style:
                                                TextStyle(color: Colors.white)),
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 32, bottom: 16),
                                            child: Text(version.join("\n\n"),
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Divider()
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

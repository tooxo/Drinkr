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
  List<List<String>> items = new List<List<String>>();
  Map<String, List<List<String>>> itemMap =
      new Map<String, List<List<String>>>();

  void populateItems() async {
    await LicenseRegistry.licenses.forEach((license) {
      List<String> appendable = List<String>();
      appendable.add(license.packages.join(", "));
      for (String package in license.packages) {
        if (!itemMap.containsKey(package)) {
          itemMap[package] = new List<List<String>>();
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

  ScrollController controller = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text(
          "about",
          style: GoogleFonts.caveatBrush(color: Colors.black, fontSize: 30),
        ).tr(),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
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
                                  style: GoogleFonts.caveatBrush(fontSize: 60),
                                ),
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                      "Created By Artjom Zakoyan and Till Schulte",
                                      style: GoogleFonts.caveatBrush(
                                          fontSize: 18)),
                                ),
                                Container(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 40,
                                  width: double.infinity,
                                  child: FlatButton.icon(
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
                                    ),
                                    label: Text(
                                      "GitHub",
                                      style:
                                          GoogleFonts.caveatBrush(fontSize: 25),
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
                  style: GoogleFonts.caveatBrush(fontSize: 30),
                ),
                itemMap.isEmpty
                    ? SpinKitFadingCircle(
                        color: Colors.black,
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
                                  subtitle1: TextStyle(color: Colors.black)),
                              accentColor: Colors.black),
                          child: ExpansionTile(
                            title: Text(
                              package,
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
                                        ),
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 32, bottom: 16),
                                            child: Text(version.join("\n\n")),
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

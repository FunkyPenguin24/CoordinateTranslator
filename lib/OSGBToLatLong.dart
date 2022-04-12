import 'dart:convert';

import 'package:coord_translator/What3WordsWrapper.dart';
import 'package:coord_translator/settingsManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what3words/what3words.dart' as w3w;
import 'package:fluttertoast/fluttertoast.dart';

class OSGBToLatLong extends StatefulWidget {

  final SettingsManager sm;

  OSGBToLatLong(this.sm);

  OSGBToLatLongState createState() => OSGBToLatLongState();
}

class OSGBToLatLongState extends State<OSGBToLatLong> with AutomaticKeepAliveClientMixin<OSGBToLatLong> {

  @override
  bool get wantKeepAlive => true;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController eastingController = TextEditingController();
  FocusNode eastingFocus = FocusNode();
  TextEditingController northingController = TextEditingController();
  FocusNode northingFocus = FocusNode();
  TextEditingController numRefController = TextEditingController();
  FocusNode numRefFocus = FocusNode();
  TextEditingController letterRefController = TextEditingController();

  TextEditingController latController = TextEditingController();
  TextEditingController latDmsController = TextEditingController();
  TextEditingController longController = TextEditingController();
  TextEditingController longDmsController = TextEditingController();
  TextEditingController fullDecController = TextEditingController();
  TextEditingController fullDmsController = TextEditingController();

  LatLongConverter converter = new LatLongConverter();

  double? latDec;
  double? longDec;
  dynamic latDms;
  dynamic longDms;
  bool converted = false;

  TextEditingController threeWordsController = TextEditingController();

  void clearField(TextEditingController field) {
    field.text = "";
    if (field == eastingController || field == northingController) {
      updateFullRefText();
    } else {
      updateEastingNorthingText();
    }
  }

  void clearAllFields() {
    eastingController.text = "";
    northingController.text = "";
    numRefController.text = "";
    letterRefController.text = "";

    threeWordsController.text = "";

    latDec = null;
    longDec = null;
    latDms = null;
    longDms = null;

    setState(() {
      converted = false;
    });

    updateFields();
  }

  void copyFieldToClipboard(TextEditingController field) {
    if (field.text.isNotEmpty) {
      Clipboard.setData(new ClipboardData(text: field.text));
      showToast("Copied to clipboard");
    } else {
      showToast("Nothing to copy");
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(msg: message);
  }

  void updateFullRefText() {
    numRefController.text = eastingController.text + " " + northingController.text;
  }

  void updateEastingNorthingText() {
    if (numRefController.text.contains(" ")) {
      var eN = numRefController.text.split(" ");
      eastingController.text = eN[0];
      northingController.text = eN[1];
    } else {
      eastingController.text = numRefController.text;
      northingController.text = "";
    }
  }

  void convert() {
    if (_formKey.currentState!.validate()) {
      try {
        LatLong result;
        OSRef os;
        if (widget.sm.settings["OS type"] == "Letter") { //if the user has selected to input the os reference in letter pair mode, use the letter pair textbox
          os = OSRef.fromLetterRef(letterRefController.text);
          result = converter.getLatLongFromOSGBLetterRef(os.letterRef);
        } else { //otherwise use the easting and northing text boxes
          os = OSRef(int.parse(eastingController.text), int.parse(northingController.text));
          result = converter.getLatLongFromOSGB(os.easting, os.northing);
        }

        latDec = result.lat;
        longDec = result.long;

        latDms = converter.getDegreeFromDecimal(latDec!);
        longDms = converter.getDegreeFromDecimal(longDec!);

        letterRefController.text = os.letterRef;
        eastingController.text = os.easting.toString();
        northingController.text = os.northing.toString();
        numRefController.text = os.numericalRef;

        if (widget.sm.settings["What3Words"])
          getWhatThreeWords(result);

        setState(() {
          converted = true;
        });

        updateFields();
      } catch (ex) {
        showErrorMessage(ex.toString());
      }
    }
  }

  void getWhatThreeWords(LatLong latLong) async {
    var api = w3w.What3WordsV3(TOKEN);
    var words = await api
      .convertTo3wa(w3w.Coordinates(latLong.lat, latLong.long))
      .language('en')
      .execute();
    threeWordsController.text = words.data()?.words ?? "No connection";
  }

  convertDecimalDegree(String type) {
    this.setState(() {
      widget.sm.settings["Lat/Long output"] = type;
      widget.sm.saveSettings();
    });
    updateFields();
  }

  updateFields() {
    String type = widget.sm.settings["Lat/Long output"];
    latController.text = (latDec != null) ? "${latDec!.toStringAsFixed(4)}" : "";
    longController.text = (longDec != null) ? "${longDec!.toStringAsFixed(4)}" : "";
    latDmsController.text = (latDms != null) ? "${latDms[0]}° ${latDms[1]}' ${latDms[2].toStringAsFixed(4)}\"" : "";
    longDmsController.text = (longDms != null) ? "${longDms[0]}° ${longDms[1]}' ${longDms[2].toStringAsFixed(4)}\"" : "";
    fullDecController.text = (latDec != null) ? "N ${latDec!.toStringAsFixed(4)}, E ${longDec!.toStringAsFixed(4)}" : "";
    fullDmsController.text = (latDms != null) ? "N ${latDms[0]}° ${latDms[1]}' ${latDms[2].toStringAsFixed(4)}\", E ${longDms[0]}° ${longDms[1]}' ${longDms[2].toStringAsFixed(4)}\"" : "";
  }

  void showErrorMessage(String ex) {
    print(ex);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(ex),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  openInMap(double lat, double long) async {
    final List<AvailableMap> availableMaps = await MapLauncher.installedMaps;
    final coords = Coords(lat, long);
    final details = await SharedPreferences.getInstance();
    AvailableMap? selectedMap = (details.containsKey("map")) ? AvailableMap.fromJson(jsonDecode(details.getString("map")!)) : null;
    if (selectedMap != null) {
      selectedMap.showMarker(coords: coords, title: "Location");
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Wrap(
                    children: [
                      for (dynamic map in availableMaps)
                        ListTile(
                          onTap: () {
                            setState(() {
                              selectedMap = map;
                            });
                          },
                          title: Text(map.mapName),
                          tileColor: (selectedMap == map) ? Colors.blue : null,
                          leading: SvgPicture.asset(
                            map.icon,
                            height: 30.0,
                            width: 30.0,
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              child: Text("Just once"),
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>((selectedMap != null) ? Colors.blue : Colors.grey),
                              ),
                              onPressed: (selectedMap != null) ? () {
                                selectedMap!.showMarker(coords: coords, title: "Location");
                                Navigator.pop(context);
                              } : null,
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              child: Text("Always"),
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>((selectedMap != null) ? Colors.blue : Colors.grey),
                              ),
                              onPressed: (selectedMap != null) ? () {
                                Map<String, dynamic> json = { //package does not provide json encodable object
                                  "mapName":selectedMap!.mapName,
                                  "mapType":selectedMap!.mapType.toString().split(".").last,
                                };
                                details.setString("map", jsonEncode(json));
                                selectedMap!.showMarker(coords: coords, title: "Location");
                                Navigator.pop(context);
                              } : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String type = widget.sm.settings["Lat/Long output"]!;
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Switch to " + ((widget.sm.settings["OS type"] == "Letter") ? "numerical ref" : "letter ref"),
                            ),
                          ),
                          Icon(Icons.swap_horiz)
                        ],
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (widget.sm.settings["OS type"] == "Letter") {
                        setState(() {
                          widget.sm.settings["OS type"] = "Numerical";
                        });
                      } else {
                        setState(() {
                          widget.sm.settings["OS type"] = "Letter";
                        });
                      }
                      widget.sm.saveSettings();
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: 16.0)),
                Expanded(
                  child: ElevatedButton(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              (widget.sm.settings["Lat/Long output"] == "Decimal") ? "Switch to degrees" : "Switch to decimal",
                            ),
                          ),
                          Expanded(child: Icon(Icons.swap_horiz),),
                        ],
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (widget.sm.settings["Lat/Long output"] == "Decimal") {
                        convertDecimalDegree("Degrees");
                      } else {
                        convertDecimalDegree("Decimal");
                      }
                    },
                  ),
                ),
              ],
            ), //top 2 buttons

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Visibility(
              visible: !(widget.sm.settings["OS type"] == "Letter"),
              child: Container(
                padding: EdgeInsets.only(bottom: 16.0),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Easting",
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          TextFormField(
                            controller: eastingController,
                            focusNode: eastingFocus,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter a valid Easting!";
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              northingFocus.requestFocus();
                            },
                            onChanged: (value) {
                              updateFullRefText();
                              if (value.length == 6) {
                                northingFocus.requestFocus();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "460334",
                              suffixIcon: SizedBox(
                                width: 50,
                                child: IconButton(
                                  icon: Icon(Icons.clear),
                                  iconSize: 18.0,
                                  onPressed: () => clearField(eastingController),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 5.0)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Northing",
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          TextFormField(
                            controller: northingController,
                            focusNode: northingFocus,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Enter a valid Northing!";
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              convert();
                            },
                            onChanged: (value) {
                              updateFullRefText();
                              if (value.length == 6) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "452192",
                              suffixIcon: SizedBox(
                                width: 50,
                                child: IconButton(
                                  icon: Icon(Icons.clear),
                                  iconSize: 18.0,
                                  onPressed: () => clearField(northingController),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ), //easting northing

            Visibility(
              visible: !(widget.sm.settings["OS type"] == "Letter"),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Full numerical reference",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: numRefController,
                    focusNode: numRefFocus,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter a valid reference!";
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      convert();
                    },
                    onChanged: (value) {
                      updateEastingNorthingText();
                      if (value.length == 13) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "460334 452192",
                      suffixIcon: SizedBox(
                        width: 50,
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          iconSize: 18.0,
                          onPressed: () => clearField(numRefController),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ), //full numerical ref

            Visibility(
              visible: widget.sm.settings["OS type"] == "Letter",
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Full letter reference",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: letterRefController,
                    //enabled: widget.sm.settings["OS type"] == "Letter",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter a valid reference!";
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      convert();
                    },
                    decoration: InputDecoration(
                      hintText: "SE 60334 52192",
                      suffixIcon: SizedBox(
                        width: 50,
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          iconSize: 18.0,
                          onPressed: () => clearField(letterRefController),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ), //full letter ref

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: Text(
                      "Convert",
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      convert();
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: 10.0)),
                Expanded(
                  child: ElevatedButton(
                    child: Text(
                      "Clear all",
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      clearAllFields();
                    },
                  ),
                ),
              ],
            ), //middle 2 buttons

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Row(
              children: [
                Text(
                  "Latitude ($type) N",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: (widget.sm.settings["Lat/Long output"] == "Decimal") ? latController : latDmsController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Latitude",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.content_copy),
                  iconSize: 18.0,
                  onPressed: () => copyFieldToClipboard(latController),
                ),
              ],
            ),

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Row(
              children: [
                Text(
                  "Longitude ($type) E",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: (widget.sm.settings["Lat/Long output"] == "Decimal") ? longController : longDmsController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Longitude",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.content_copy),
                  iconSize: 18.0,
                  onPressed: () => copyFieldToClipboard(longController),
                ),
              ],
            ),

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Row(
              children: [
                Text(
                    "Latitude and Longitude ($type)",
                    style: TextStyle(
                      fontSize: 20.0,
                    )
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: (type == "Decimal") ? fullDecController: fullDmsController,
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: "Latitude and Longitude",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.content_copy),
                  iconSize: 18.0,
                  onPressed: () => copyFieldToClipboard((type == "Decimal") ? fullDecController: fullDmsController),
                ),
              ],
            ),

            Visibility(
              visible: widget.sm.settings["What3Words"],
              child: Container(
                child: Row(
                    children: [
                      Text(
                        "///",
                        style: TextStyle(
                          color: Color.fromRGBO(225, 31, 38, 1),
                          fontSize: 20.0,
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: threeWordsController,
                          enabled: false,
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                          decoration: InputDecoration(
                            hintText: "what.three.words",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.content_copy),
                        iconSize: 18.0,
                        onPressed: () => copyFieldToClipboard(threeWordsController),
                      ),
                    ]
                ),
              ),
            ), //w3w



            Visibility(
              visible: converted,
              child: Container(
                child: Row(
                  children: [
                    ElevatedButton(
                      child: Text("Show on map"),
                      onPressed: () {
                        openInMap(double.parse(latController.text), double.parse(longController.text));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

}
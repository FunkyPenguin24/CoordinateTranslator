import 'dart:convert';

import 'package:coord_translator/settingsManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what3words/what3words.dart' as w3w;
import 'package:fluttertoast/fluttertoast.dart';
import 'What3WordsWrapper.dart';

class LatLongToOSGB extends StatefulWidget {

  final SettingsManager sm;
  LatLongToOSGB(this.sm);

  LatLongToOSGBState createState() => LatLongToOSGBState();
}

class LatLongToOSGBState extends State<LatLongToOSGB> with AutomaticKeepAliveClientMixin<LatLongToOSGB> {

  @override
  bool get wantKeepAlive => true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController latController = TextEditingController();
  FocusNode latFocus = FocusNode();
  TextEditingController longController = TextEditingController();
  FocusNode longFocus = FocusNode();

  TextEditingController latDegController = TextEditingController();
  FocusNode latDegFocus = FocusNode();
  TextEditingController latMinController = TextEditingController();
  FocusNode latMinFocus = FocusNode();
  TextEditingController latSecController = TextEditingController();
  FocusNode latSecFocus = FocusNode();

  TextEditingController longDegController = TextEditingController();
  FocusNode longDegFocus = FocusNode();
  TextEditingController longMinController = TextEditingController();
  FocusNode longMinFocus = FocusNode();
  TextEditingController longSecController = TextEditingController();
  FocusNode longSecFocus = FocusNode();

  TextEditingController eastingController = TextEditingController();
  TextEditingController northingController = TextEditingController();
  TextEditingController numRefController = TextEditingController();
  TextEditingController letterRefController = TextEditingController();

  LatLongConverter converter = new LatLongConverter();

  TextEditingController threeWordsController = TextEditingController();

  bool converted = false;

  void locate() async {
    Location location = new Location();

    PermissionStatus permissionGiven = await location.hasPermission();
    if (permissionGiven == PermissionStatus.denied) {
      permissionGiven = await location.requestPermission();
      if (permissionGiven != PermissionStatus.granted) {
        showErrorMessage("Without location permission, the app will not be able to find you");
        return;
      }
    }

    bool locationEnabled = await location.serviceEnabled();
    if (!locationEnabled) {
      locationEnabled = await location.requestService();
      if (!locationEnabled) { //if the user declines to turn on locations
        showErrorMessage("Without location turned on the app will not be able to find you");
        return;
      }
    }

    LocationData currentPos = await location.getLocation();
    double latitude = currentPos.latitude!;
    double longitude = currentPos.longitude!;

    latController.text = "$latitude";
    longController.text = "$longitude";

    var latDegrees = converter.getDegreeFromDecimal(latitude);
    latDegController.text = "${latDegrees[0]}";
    latMinController.text = "${latDegrees[1]}";
    latSecController.text = "${latDegrees[2]}";

    var longDegrees = converter.getDegreeFromDecimal(longitude);
    longDegController.text = "${longDegrees[0]}";
    longMinController.text = "${longDegrees[1]}";
    longSecController.text = "${longDegrees[2]}";
  }

  void convert() async {
    if (_formKey.currentState!.validate()) {
      try {
      } catch (ex) {
        showErrorMessage(ex.toString());
        throw ex;
      }
      LatLong latLong;
      OSRef result; //result will be osref
      if (widget.sm.settings["Lat/Long type"] == "Decimal") {
        result = converter.getOSGBfromDec(double.parse(latController.text), double.parse(longController.text));
        latLong = new LatLong(double.parse(latController.text), double.parse(longController.text), 0, Datums.WGS84);
      } else {
        result = converter.getOSGBfromDms(double.parse(latDegController.text), double.parse(latMinController.text), double.parse(latSecController.text), double.parse(longDegController.text), double.parse(longMinController.text), double.parse(longSecController.text));
        latLong = new LatLong.fromDms(double.parse(latDegController.text), double.parse(latMinController.text), double.parse(latSecController.text), double.parse(longDegController.text), double.parse(longMinController.text), double.parse(longSecController.text), 0, Datums.WGS84);
      }

      String easting, northing, numRef, letterRef;
      easting = "${result.easting}";
      northing = "${result.northing}";
      numRef = result.numericalRef;
      letterRef = result.letterRef;

      eastingController.text = easting;
      northingController.text =  northing;
      numRefController.text = numRef;
      letterRefController.text = letterRef;
      if (widget.sm.settings["What3Words"])
        getWhatThreeWords(latLong);

      setState(() {
        converted = true;
      });
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
    if (type == "Decimal") {
      if (latDegreeFilled()) {
        double decimal = converter.getDecimalFromDegree(double.parse(latDegController.text), double.parse(latMinController.text), double.parse(latSecController.text));
        latController.text = "$decimal";
      }
      if (longDegreeFilled()) {
        double decimal = converter.getDecimalFromDegree(double.parse(longDegController.text), double.parse(longMinController.text), double.parse(longSecController.text));
        longController.text = "$decimal";
      }
    } else {
      if (latDecimalFilled()) {
        var degrees = converter.getDegreeFromDecimal(double.parse(latController.text));
        latDegController.text = "${degrees[0]}";
        latMinController.text = "${degrees[1]}";
        latSecController.text = "${degrees[2]}";
      }
      if (longDecimalFilled()) {
        var degrees = converter.getDegreeFromDecimal(double.parse(longController.text));
        longDegController.text = "${degrees[0]}";
        longMinController.text = "${degrees[1]}";
        longSecController.text = "${degrees[2]}";
      }
    }
    setState(() {
      widget.sm.settings["Lat/Long type"] = type;
    });
    widget.sm.saveSettings();
  }

  void clearField(TextEditingController field) {
    field.text = "";
  }

  void clearAllFields() {
    latController.text = "";
    latDegController.text = "";
    latMinController.text = "";
    latSecController.text = "";

    longController.text = "";
    longDegController.text = "";
    longMinController.text = "";
    longSecController.text = "";

    eastingController.text = "";
    northingController.text = "";
    numRefController.text = "";
    letterRefController.text = "";

    threeWordsController.text = "";

    setState(() {
      converted = false;
    });
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

  bool latDegreeFilled() => (latDegController.text.isNotEmpty && latMinController.text.isNotEmpty && latSecController.text.isNotEmpty);
  bool longDegreeFilled() => (longDegController.text.isNotEmpty && longMinController.text.isNotEmpty && longSecController.text.isNotEmpty);

  bool latDecimalFilled() => latController.text.isNotEmpty;
  bool longDecimalFilled() => longController.text.isNotEmpty;


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
    String type = widget.sm.settings["Lat/Long type"]!;
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
                              "Use my location! ",
                            ),
                          ),
                          Expanded(child: Icon(Icons.my_location),)
                        ],
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      locate();
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
                              (widget.sm.settings["Lat/Long type"] == "Decimal") ? "Switch to degrees" : "Switch to decimal",
                            ),
                          ),
                          Expanded(child: Icon(Icons.swap_horiz),),
                        ],
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (widget.sm.settings["Lat/Long type"] == "Decimal") {
                        convertDecimalDegree("Degrees");
                      } else {
                        convertDecimalDegree("Decimal");
                      }
                    },
                  ),
                ),
              ],
            ),

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Row(
              children: [
                Text(
                  "Latitude (${widget.sm.settings["Lat/Long type"]}) N",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            (type == "Decimal") ?
            TextFormField(
              controller: latController,
              focusNode: latFocus,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter a valid Latitude!";
                }
                return null;
              },
              onFieldSubmitted: (value) {
                longFocus.requestFocus();
              },
              decoration: InputDecoration(
                hintText: "53.9623",
                suffixIcon: SizedBox(
                  width: 50,
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    iconSize: 18.0,
                    onPressed: () => clearField(latController),
                  ),
                ),
              ),
            ) :
            Column(
              children: [
                TextFormField(
                  controller: latDegController,
                  focusNode: latDegFocus,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter valid degrees!";
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    latMinFocus.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Degrees",
                    suffixIcon: SizedBox(
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 18.0,
                        onPressed: () => clearField(latDegController),
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: latMinController,
                  focusNode: latMinFocus,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter valid minutes!";
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    latSecFocus.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Minutes",
                    suffixIcon: SizedBox(
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 18.0,
                        onPressed: () => clearField(latMinController),
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: latSecController,
                  focusNode: latSecFocus,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter valid seconds!";
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    longDegFocus.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Seconds",
                    suffixIcon: SizedBox(
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 18.0,
                        onPressed: () => clearField(latSecController),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Row(
              children: [
                Text(
                  "Longitude (${widget.sm.settings["Lat/Long type"]}) E",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            (type == "Decimal") ?
            TextFormField(
              controller: longController,
              focusNode: longFocus,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter a valid Longitude!";
                }
                return null;
              },
              onFieldSubmitted: (value) {
                longFocus.unfocus();
                convert();
              },
              decoration: InputDecoration(
                hintText: "-1.0819",
                suffixIcon: SizedBox(
                  width: 50,
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    iconSize: 18.0,
                    onPressed: () => clearField(longController),
                  ),
                ),
              ),
            ) :
            Column(
              children: [
                TextFormField(
                  controller: longDegController,
                  focusNode: longDegFocus,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter valid degrees!";
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    longMinFocus.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Degrees",
                    suffixIcon: SizedBox(
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 18.0,
                        onPressed: () => clearField(longDegController),
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: longMinController,
                  focusNode: longMinFocus,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter valid minutes!";
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    longSecFocus.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Minutes",
                    suffixIcon: SizedBox(
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 18.0,
                        onPressed: () => clearField(longMinController),
                      ),
                    ),
                  ),
                ),
                TextFormField(
                  controller: longSecController,
                  focusNode: longSecFocus,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter valid seconds!";
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    longSecFocus.unfocus();
                    convert();
                  },
                  decoration: InputDecoration(
                    labelText: "Seconds",
                    suffixIcon: SizedBox(
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.clear),
                        iconSize: 18.0,
                        onPressed: () => clearField(longSecController),
                      ),
                    ),
                  ),
                ),
              ],
            ),

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
                Padding(padding: EdgeInsets.only(right: 16.0)),
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
            ), //buttons

            Visibility(
              visible: widget.sm.settings["EastingNorthing"],
              child: Container(
                padding: EdgeInsets.only(top: 16.0),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: eastingController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: "460334",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.content_copy),
                                iconSize: 18.0,
                                onPressed: () => copyFieldToClipboard(eastingController),
                              ),
                            ],
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: northingController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: "452192",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.content_copy),
                                iconSize: 18.0,
                                onPressed: () => copyFieldToClipboard(northingController),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ) ,//easting northing

            Visibility(
              visible: widget.sm.settings["Numerical"],
              child: Container(
                padding: EdgeInsets.only(top: 16.0),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: numRefController,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: "460334 452192",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.content_copy),
                          iconSize: 18.0,
                          onPressed: () => copyFieldToClipboard(numRefController),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ), //numerical ref

            Visibility(
              visible: widget.sm.settings["Letter"],
              child: Container(
                  padding: EdgeInsets.only(top: 16.0),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: letterRefController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: "SE 60334 52192",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.content_copy),
                            iconSize: 18.0,
                            onPressed: () => copyFieldToClipboard(letterRefController),
                          ),
                        ],
                      ),
                    ],
                  )
              ),
            ), //letter ref

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
              )
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
      ),
    );
  }

}
import 'package:coord_translator/What3WordsWrapper.dart';
import 'package:coord_translator/settingsManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
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
  TextEditingController longController = TextEditingController();

  LatLongConverter converter = new LatLongConverter();

  double? latDec;
  double? longDec;
  dynamic? latDms;
  dynamic? longDms;

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
    if (widget.sm.settings["Lat/Long output"] == "Decimal") {
      latController.text = (latDec != null) ? "${latDec!.toStringAsFixed(4)}" : "";
      longController.text = (longDec != null) ? "${longDec!.toStringAsFixed(4)}" : "";
    } else {
      latController.text = (latDms != null) ? "${latDms[0]}° ${latDms[1]}' ${latDms[2].toStringAsFixed(4)}\"" : "";
      longController.text = (longDms != null) ? "${longDms[0]}° ${longDms[1]}' ${longDms[2].toStringAsFixed(4)}\"" : "";
    }
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
            ),

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Visibility(
              visible: !(widget.sm.settings["OS type"] == "Letter"),
              child: Container(
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
            ),

            Visibility(
              visible: !(widget.sm.settings["OS type"] == "Letter"),
              child: Padding(padding: EdgeInsets.only(bottom: 16.0)),
            ),

            Visibility(
              visible: !(widget.sm.settings["OS type"] == "Letter"),
              child: Row(
                children: [
                  Text(
                    "Full numerical reference",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: !(widget.sm.settings["OS type"] == "Letter"),
              child: TextFormField(
                controller: numRefController,
                focusNode: numRefFocus,
                //enabled: !(widget.sm.settings["OS type"] == "Letter"),
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
            ),

            Visibility(
              visible: widget.sm.settings["OS type"] == "Letter",
              child: Row(
                children: [
                  Text(
                    "Full letter reference",
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.sm.settings["OS type"] == "Letter",
              child: TextFormField(
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
            ),

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
                    controller: latController,
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
                    controller: longController,
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
            ),
          ],
        ),
      )
    );
  }

}
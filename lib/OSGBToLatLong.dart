import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';

class OSGBToLatLong extends StatefulWidget {

  Function(LatLong, OSRef) callback;
  Map<String, String> settings;

  OSGBToLatLong(this.settings, this.callback);

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
  bool letterPairInput = true;

  double latDec;
  double longDec;
  var latDms;
  var longDms;

  void clearField(TextEditingController field) {
    field.text = "";
    if (field == eastingController || field == northingController) {
      updateFullRefText();
    } else {
      updateEastingNorthingText();
    }
  }

  void clearAllFields() {
    latController.text = "";

    longController.text = "";

    eastingController.text = "";
    northingController.text = "";
    numRefController.text = "";
    letterRefController.text = "";
  }

  void copyFieldToClipboard(TextEditingController field) {
    Clipboard.setData(new ClipboardData(text: field.text));
    showSnackBar("Copied to clipbaord");
  }

  void showSnackBar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void updateFullRefText() {
    numRefController.text = eastingController.text + "," + northingController.text;
  }

  void updateEastingNorthingText() {
    if (numRefController.text.contains(",")) {
      var eN = numRefController.text.split(",");
      eastingController.text = eN[0];
      northingController.text = eN[1];
    } else {
      eastingController.text = numRefController.text;
      northingController.text = "";
    }
  }

  void convert() {
    if (_formKey.currentState.validate()) {
      try {
        LatLong result;
        OSRef os;
        if (letterPairInput) { //if the user has selected to input the os reference in letter pair mode, use the letter pair textbox
          os = OSRef.fromLetterRef(letterRefController.text);
          result = converter.getLatLongFromOSGBLetterRef(os.letterRef);
        } else { //otherwise use the easting and northing text boxes
          os = OSRef(int.parse(eastingController.text), int.parse(northingController.text));
          result = converter.getLatLongFromOSGB(os.easting, os.northing);
        }

        latDec = result.lat;
        longDec = result.long;

        latDms = converter.getDegreeFromDecimal(latDec);
        longDms = converter.getDegreeFromDecimal(longDec);

        letterRefController.text = os.letterRef;
        eastingController.text = os.easting.toString();
        northingController.text = os.northing.toString();
        numRefController.text = os.numericalRef;

        widget.callback(result, os);
        updateFields();
      } catch (ex) {
        showErrorMessage(ex.toString());
      }
    }
  }

  convertDecimalDegree(String type) {
    this.setState(() {
      widget.settings["Lat/Long type"] = type;
    });
    updateFields();
  }

  updateFields() {
    if (widget.settings["Lat/Long type"] == "Decimal") {
      latController.text = (latDec == null) ? "" : "${latDec.toStringAsFixed(4)}";
      longController.text = (longDec == null) ? "" : "${longDec.toStringAsFixed(4)}";
    } else {
      latController.text = (latDec == null) ? "" : "${latDms[0]}° ${latDms[1]}' ${latDms[2].toStringAsFixed(4)}\"";
      longController.text = (longDec == null) ? "" : "${longDms[0]}° ${longDms[1]}' ${longDms[2].toStringAsFixed(4)}\"";
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
            FlatButton(
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
    String type = widget.settings["Lat/Long type"];
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
                  child: RaisedButton(
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Switch to " + ((letterPairInput) ? "numerical" : "letter"),
                            ),
                          ),
                          Icon(Icons.swap_horiz)
                        ],
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      this.setState(() {
                        letterPairInput = !letterPairInput;
                      });
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: 16.0)),
                Expanded(
                  child: RaisedButton(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              (widget.settings["Lat/Long type"] == "Decimal") ? "Switch to degrees" : "Switch to decimal",
                            ),
                          ),
                          Expanded(child: Icon(Icons.swap_horiz),),
                        ],
                      ),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (widget.settings["Lat/Long type"] == "Decimal") {
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
              visible: !letterPairInput,
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
                              if (value.isEmpty) {
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
                              if (value.isEmpty) {
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
              visible: !letterPairInput,
              child: Padding(padding: EdgeInsets.only(bottom: 16.0)),
            ),

            Visibility(
              visible: !letterPairInput,
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
              visible: !letterPairInput,
              child: TextFormField(
                controller: numRefController,
                focusNode: numRefFocus,
                enabled: !letterPairInput,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value.isEmpty) {
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
                  hintText: "460334,452192",
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
              visible: letterPairInput,
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
              visible: letterPairInput,
              child: TextFormField(
                controller: letterRefController,
                enabled: letterPairInput,
                validator: (value) {
                  if (value.isEmpty) {
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
                  child: RaisedButton(
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
                  child: RaisedButton(
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
          ],
        ),
      )
    );
  }

}
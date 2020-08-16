import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'converter.dart';
import 'maths/LatLong.dart';

class OSGBToLatLong extends StatefulWidget {

  Map<String, String> settings;

  OSGBToLatLong(this.settings);

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
  TextEditingController fullRefController = TextEditingController();
  FocusNode fullRefFocus = FocusNode();

  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();

  Converter converter = new Converter();

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
    fullRefController.text = "";
  }

  void copyFieldToClipboard(TextEditingController field) {
    Clipboard.setData(new ClipboardData(text: field.text));
    showSnackBar("Copied to clipbaord");
  }

  void showSnackBar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void updateFullRefText() {
    fullRefController.text = eastingController.text + "," + northingController.text;
  }

  void updateEastingNorthingText() {
    if (fullRefController.text.contains(",")) {
      var eN = fullRefController.text.split(",");
      eastingController.text = eN[0];
      northingController.text = eN[1];
    } else {
      eastingController.text = fullRefController.text;
      northingController.text = "";
    }
  }

  void convert() {
    if (_formKey.currentState.validate()) {
      try {
        LatLong result = converter.getLatLongFromOSGB(double.parse(eastingController.text), double.parse(northingController.text));
        latDec = result.lat;
        longDec = result.long;

        latDms = converter.getDegreeFromDecimal(latDec);
        longDms = converter.getDegreeFromDecimal(longDec);
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
      latController.text = (latDec == null) ? "" : "$latDec";
      longController.text = (longDec == null) ? "" : "$longDec";
    } else {
      latController.text = (latDec == null) ? "" : "${latDms[0]}° ${latDms[1]}' ${latDms[2]}\"";
      longController.text = (longDec == null) ? "" : "${longDms[0]}° ${longDms[1]}' ${longDms[2]}\"";
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
  Widget build(BuildContext build) {
    String type = widget.settings["Lat/Long type"];
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Easting",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      Container(
                        width: 150,
                        child: TextFormField(
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
                            hintText: "123456",
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
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(right: 5.0)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Northing",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      Container(
                        width: 150,
                        child: TextFormField(
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
                            hintText: "654321",
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
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            Row(
              children: [
                Text(
                  "Full OS grid reference",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: fullRefController,
              focusNode: fullRefFocus,
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
                hintText: "123456,654321",
                suffixIcon: SizedBox(
                  width: 50,
                  child: IconButton(
                    icon: Icon(Icons.clear),
                    iconSize: 18.0,
                    onPressed: () => clearField(fullRefController),
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

            Padding(padding: EdgeInsets.only(top: 16.0)),

            Container(
              width: 150,
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
            )
          ],
        ),
      )
    );
  }

}
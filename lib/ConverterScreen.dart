import 'package:flutter/material.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'Places.dart';
//import 'SideDrawer.dart';
import 'LatLongToOSGB.dart';
import 'OSGBToLatLong.dart';

class ConverterScreen extends StatefulWidget {

  ConverterScreenState createState() => ConverterScreenState();

}

class ConverterScreenState extends State<ConverterScreen> with SingleTickerProviderStateMixin {
  final tabs = ["Lat/Long to OSGB", "OSGB to Lat/Long"];
  GlobalKey<FormState> _formKey = new GlobalKey();
  PlaceManager pm = new PlaceManager();
  late Place currPlace;
  late TabController tabControl;

  Map<String, String> settings = {
    "Lat/Long type":"Decimal"
  };

  @override
  initState() {
    super.initState();
    loadFavPlaces();
    tabControl = new TabController(vsync: this, length: 2);
    tabControl.addListener(() {
      if (tabControl.indexIsChanging) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void loadFavPlaces() async {
    await pm.loadFavPlaces();
  }

  void addCurrToFav(String n, String d) async {
    currPlace.name = n;
    currPlace.desc = d;
    pm.addFavPlace(currPlace);
    await pm.saveFavPlaces();
  }

  getFavDetails() {
    TextEditingController nameControl = new TextEditingController();
    TextEditingController descControl = new TextEditingController();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add favourite place"),
          content: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Text("Name"),
                Padding(padding: EdgeInsets.only(top: 5.0)),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Name",
                  ),
                  controller: nameControl,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter a valid name";
                    }
                    return null;
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Text("Description"),
                Padding(padding: EdgeInsets.only(top: 5.0)),
                TextField(
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Description (optional)",
                  ),
                  controller: descControl,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Add"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (descControl.text.isEmpty) {
                    addCurrToFav(nameControl.text, "");
                  } else {
                    addCurrToFav(nameControl.text, descControl.text);
                  }
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }

  showMustConvertDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error!"),
          content: Text("You must first complete a conversion before you can favourite a place"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          // drawer: SideDrawer(widget),
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Coordinate Translator",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            bottom: TabBar(
              controller: tabControl,
              isScrollable: false,
              tabs: [
                for (final tab in tabs) Tab(text: tab),
              ],
              onTap: (index) {
                FocusScope.of(context).unfocus();
                tabControl.animateTo(index);
              },
            ),
            // actions: [
            //   FlatButton(
            //     onPressed: () {
            //       if (currPlace == null) {
            //         showMustConvertDialog();
            //       } else {
            //         getFavDetails();
            //       }
            //     },
            //     child: Icon(Icons.favorite),
            //   ),
            // ],
          ),
          body: TabBarView(
            controller: tabControl,
            children: [
              for (final tab in tabs)
                SingleChildScrollView(
                  child: getTabView(tab),
                ),
            ],
          ),
        )
    );
  }

  Widget? getTabView(String tab) {
    switch (tab) {
      case "Lat/Long to OSGB": return LatLongToOSGB(settings, setCurrentPlace); break;
      case "OSGB to Lat/Long": return OSGBToLatLong(settings, setCurrentPlace); break;
      default: return null; break;
    }
  }

  void setCurrentPlace(LatLong latLong, OSRef gridRef) {
    currPlace = new Place("", "", latLong, gridRef, "");
  }

}
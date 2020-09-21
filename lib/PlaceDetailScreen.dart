import 'package:flutter/material.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Places.dart';
import 'SideDrawer.dart';

class PlaceDetailScreen extends StatefulWidget {

  final Place place;

  PlaceDetailScreen(this.place);

  PlaceDetailScreenState createState() => PlaceDetailScreenState();

}

class PlaceDetailScreenState extends State<PlaceDetailScreen> {
  PlaceManager pm = new PlaceManager();
  bool editing = false;

  @override
  initState() {
    super.initState();
    loadPlaces();
  }

  loadPlaces() async {
    await pm.loadFavPlaces();
  }

  deletePlace() async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm deletion"),
          content: Text("Are you sure you would like to delete the place " + widget.place.name + "?"),
          actions: [
            FlatButton(
              child: Text("Confirm"),
              onPressed: () async {
                pm.removeFavPlace(widget.place);
                await pm.saveFavPlaces();
                Navigator.pop(context);
                Navigator.pop(context, "refresh");
              },
            ),
            FlatButton(
              child: Text("Cancel"),
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
    List<dynamic> latDms = LatLongConverter().getDegreeFromDecimal(widget.place.latLong.getLat());
    List<dynamic> lonDms = LatLongConverter().getDegreeFromDecimal(widget.place.latLong.getLon());
    return Scaffold(
      drawer: SideDrawer(widget),
      appBar: AppBar(
        title: Text(widget.place.name),
        leading: FlatButton(
          child: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: Icon((editing) ? Icons.check : Icons.edit, color: Colors.white),
              onTap: () {
                this.setState(() {
                  //editing = !editing;
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              child: Icon(Icons.delete, color: Colors.white),
              onTap: () {
                deletePlace();
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.place.name,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 15.0)),

                Text(
                  widget.place.desc,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 15.0)),

                Text(
                  "Latitude (DMS)",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 5.0)),
                Text(
                  latDms[0].toString() + "° " + latDms[1].toString() + "' " + latDms[2].toString() + "\" N",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),

                Text(
                  "Longitude (DMS)",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 5.0)),
                Text(
                  lonDms[0].toString() + "° " + lonDms[1].toString() + "' " + lonDms[2].toString() + "\" E",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),

                Text(
                  "Latitude and Longitude (decimal)",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 5.0)),
                Text(
                  widget.place.latLong.getLat().toString() +  " N " + widget.place.latLong.getLon().toString() + " E",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 15.0)),

                Text(
                  "Easting and northing: " + widget.place.gridRef.easting.toString() + ", " + widget.place.gridRef.northing.toString(),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 5.0)),
                Text(
                  "Letter reference: " + widget.place.gridRef.letterRef,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: EdgeInsets.only(bottom: 15.0, right: 15.0),
              width: 210,
              child: ButtonTheme(
                child: RaisedButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  child: Row(
                    children: [
                      Text("Open in Google Maps"),
                      Icon(Icons.location_on),
                    ],
                  ),
                  onPressed: () async {
                    final url = "https://www.google.com/maps/search/?api=1&query=${widget.place.latLong.getLat()},${widget.place.latLong.getLon()}";
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:path_provider/path_provider.dart';
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
  late File placeImage;
  late List<dynamic> latDms;
  late List<dynamic> lonDms;

  @override
  initState() {
    super.initState();
    latDms = LatLongConverter().getDegreeFromDecimal(widget.place.latLong.getLat());
    lonDms = LatLongConverter().getDegreeFromDecimal(widget.place.latLong.getLon());
    if (widget.place.imagePath != "")
      loadPlaceImage();
    loadPlaces();
  }

  loadPlaceImage() async {
    final loadDir = await getApplicationDocumentsDirectory();
    String loadPath = "${loadDir.path}/${widget.place.imagePath}";
    File newFile = File(loadPath);
    this.setState(() {
      placeImage = newFile;
    });
  }

  getImage(String source) async {
    final pickedImg = await ImagePicker().getImage(source: (source == "camera") ? ImageSource.camera : ImageSource.gallery);
    if (pickedImg != null) {
      File img = File(pickedImg.path);
      this.setState(() {
        placeImage = img;
        widget.place.imagePath = path.basename(img.path);
      });
      //fix saving issue - app can't find pictures give the file name (might be something to do with pickedimg.path but not sure)
      //look in to adding multiple pictures, maybe change imagePath in place object to a list
      final saveDir = await getApplicationDocumentsDirectory();
      String fileName = path.basename(img.path);
      String savePath = "${saveDir.path}/$fileName}";
      await img.copy(savePath);
      pm.saveFavPlaces();
    }
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
            TextButton(
              child: Text("Confirm"),
              onPressed: () async {
                pm.removeFavPlace(widget.place);
                await pm.saveFavPlaces();
                Navigator.pop(context);
                Navigator.pop(context, "refresh");
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
      },
    );
  }

  showChangeImageDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change photo"),
          actions: [
            TextButton(
              child: Text("Choose new picture from gallery"),
              onPressed: () {
                getImage("gallery");
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Take new picture"),
              onPressed: () {
                getImage("camera");
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              }
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(widget),
      appBar: AppBar(
        title: Text(widget.place.name),
        leading: TextButton(
          child: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
//          Padding( //when i have the effort editing a place needs to be implemented
//            padding: EdgeInsets.only(right: 20.0),
//            child: GestureDetector(
//              child: Icon((editing) ? Icons.check : Icons.edit, color: Colors.white),
//              onTap: () {
//                this.setState(() {
//                  //editing = !editing;
//                });
//              },
//            ),
//          ),
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
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.start,
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
                Padding(padding: EdgeInsets.only(top: 10.0)),

                Divider(
                  height: 10,
                  thickness: 2,
                ),

                Padding(padding: EdgeInsets.only(top: 10.0)),
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
                Padding(padding: EdgeInsets.only(top: 10.0)),

                Divider(
                  height: 10,
                  thickness: 2,
                ),
                Padding(padding: EdgeInsets.only(top: 10.0)),

                (widget.place.imagePath == "") ?
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Add a photo!",
                                style: TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(bottom: 5.0)),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: ElevatedButton(
                                  child: Icon(Icons.camera_alt),
                                  onPressed: () {
                                    getImage("camera");
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: ElevatedButton(
                                  child: Icon(Icons.photo),
                                  onPressed: () {
                                    getImage("gallery");
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ) :
                    InkWell(
                      child: Container(
                        child: Column(
                          children: [
                            Image.file(
                              placeImage,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        showChangeImageDialog();
                      },
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
                child: ElevatedButton(
                  // textColor: Colors.white,
                  // color: Colors.blue,
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
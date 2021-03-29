import 'dart:io';

import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;

class PlaceManager {

  List<Place> favPlaces = [];

  void addFavPlace(Place p) {
    favPlaces.add(p);
  }

  void removeFavPlace(Place p) {
    for (Place pl in favPlaces) {
      if (pl.name == p.name) {
        p = pl;
        break;
      }
    }
    favPlaces.remove(p);
  }

  loadFavPlaces() async {
    final loadDirectory = await getApplicationDocumentsDirectory();
    final file = await File("${loadDirectory.path}/favPlaces.json").create(recursive: true);
    String rawPlaces = await file.readAsString();
    if (rawPlaces != "" && rawPlaces != null) {
      List<dynamic> tempPlaces = convert.jsonDecode(rawPlaces);
      List<Place> tempList = [];
      for (int i = 0; i < tempPlaces.length; i++) {
        Place p = Place.fromJson(tempPlaces[i]);
        tempList.add(p);
      }
      favPlaces = tempList;
    }
  }

  saveFavPlaces() async {
    final saveDirectory = await getApplicationDocumentsDirectory();
    final file = await File("${saveDirectory.path}/favPlaces.json").create(recursive: true);
    file.writeAsString(convert.jsonEncode(favPlaces));
  }

}

class Place {

  String name;
  String desc;
  LatLong latLong;
  OSRef gridRef;
  String imagePath;

  Place(this.name, this.desc, this.latLong, this.gridRef, this.imagePath);

  Place.fromJson(Map<String, dynamic> json)
  : name = json['name'],
    desc = json['desc'],
    latLong = LatLong.fromJson(json['latlong']),
    gridRef = OSRef.fromJson(json['gridref']),
    imagePath = json['imagePath'];

  Map<String, dynamic> toJson() => {
    "name" : name,
    "desc" : desc,
    "latlong" : latLong.toJson(),
    "gridref" : gridRef.toJson(),
    "imagePath" : imagePath,
  };

}
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

showMap(double lat, double long, BuildContext context) async {
  MapController controller = MapController(
    initMapWithUserPosition: false,
    initPosition: GeoPoint(latitude: lat, longitude: long), //think this should create a marker but it doesn't
  );
  bool marked = false;
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location"),
          content: Container(
            height: 300,
            child: OSMFlutter(
              controller: controller,
              initZoom: 15,
              markerOption: MarkerOption(
                defaultMarker: MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 56.0,
                  ),
                ),
              ),
              onMapIsReady: (result) {
                if (marked) { //for some reason it calls this twice and the second marker is more accurate
                  controller.addMarker(GeoPoint(latitude: lat, longitude: long));
                } else {
                  marked = true;
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                controller.dispose();
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
  );
}
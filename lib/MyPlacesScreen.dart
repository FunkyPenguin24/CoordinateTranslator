import 'package:flutter/material.dart';
import 'package:latlong_to_osgrid/latlong_to_osgrid.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'PlaceDetailScreen.dart';
import 'Places.dart';

import 'SideDrawer.dart';

class MyPlacesScreen extends StatefulWidget {
  MyPlacesScreenState createState() => MyPlacesScreenState();
}

class MyPlacesScreenState extends State<MyPlacesScreen> {

  RefreshController _refreshController = RefreshController(initialRefresh: true);
  PlaceManager pm = new PlaceManager();
  List<Place> favPlaces = [];

  refreshList() async {
    await pm.loadFavPlaces();
    this.setState(() {
      favPlaces = pm.favPlaces;
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(widget),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My places",
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            getFavWidgets(),
          ],
        ),
      ),
    );
  }

  Widget getFavWidgets() {
    List<Widget> widgetList = [];

    for (Place p in favPlaces) {
      List<dynamic> latDms = LatLongConverter().getDegreeFromDecimal(p.latLong.getLat());
      List<dynamic> lonDms = LatLongConverter().getDegreeFromDecimal(p.latLong.getLon());
      widgetList.add(InkWell(
        onTap: () async {
          String result = await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PlaceDetailScreen(p)));
          if (result == "refresh")
            refreshList();
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 10.0)),
              Text(
                latDms[0].toString() + "° " + latDms[1].toString() + "' " + latDms[2].toString() + "\" N",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 5.0)),
              Text(
                lonDms[0].toString() + "° " + lonDms[1].toString() + "' " + lonDms[2].toString() + "\" E",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 5.0)),
              Text(
                p.gridRef.letterRef,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ));

      widgetList.add(Padding(padding: EdgeInsets.only(top: 15.0)));
    }

    return new SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: refreshList,
      child: ListView(
        padding: EdgeInsets.all(16.0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: widgetList,
      ),
    );
  }

}
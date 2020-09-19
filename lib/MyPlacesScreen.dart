import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'Places.dart';

import 'SideDrawer.dart';

class MyPlacesScreen extends StatefulWidget {
  MyPlacesScreenState createState() => MyPlacesScreenState();
}

class MyPlacesScreenState extends State<MyPlacesScreen> {

  RefreshController _refreshController = RefreshController(initialRefresh: true);
  PlaceManager pm = new PlaceManager();

  refreshList() {
    this.setState(() async {
      await pm.loadFavPlaces();
      _refreshController.refreshCompleted();
    });
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

      ),
    );
  }

  Widget getFavWidgets() {
    List<Widget> widgetList = new List<Widget>();

    return new SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: refreshList(),
      child: ListView(
        padding: EdgeInsets.all(16.0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: widgetList,
      ),
    );
  }

}
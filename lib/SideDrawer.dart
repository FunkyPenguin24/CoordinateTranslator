import 'package:flutter/material.dart';
import 'ConverterScreen.dart';
//import 'main.dart';
import 'MyPlacesScreen.dart';

class SideDrawer extends StatefulWidget {
  final dynamic currScreen;

  SideDrawer(this.currScreen);

  SideDrawerState createState() => SideDrawerState();

}

class SideDrawerState extends State<SideDrawer> {

  Widget build(BuildContext context) {
    return Container(
      width: 220.0,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80.0,
              child: DrawerHeader(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      "Coordinate translator",
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
            ),
            Padding(padding: EdgeInsets.only(bottom: 16.0)),
            Container(
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.all(16.0),
                leading: Icon(Icons.swap_horiz),
                title: Text(
                  "Converter",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15.0,
                  ),
                ),
                subtitle: Text(
                    "Convert between Lat/Long and OS Grid Ref"
                ),
                onTap: () {
                  //widget.callback(ConverterScreen());
                  if (!(widget.currScreen is ConverterScreen)) {
                    Navigator.pop(context);
                    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => ConverterScreen()));
                  }
                },
              ),
              decoration: BoxDecoration(
                color: (widget.currScreen is ConverterScreen) ? Colors.lightBlueAccent : Colors.white,
              ),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
            ),
            Padding(padding: EdgeInsets.only(bottom: 16.0)),
            Container(
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                dense: true,
                leading: Icon(Icons.near_me),
                title: Text(
                  "My places",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15.0,
                  ),
                ),
                subtitle: Text(
                  "Your saved places",
                ),
                onTap: () {
                  if (!(widget.currScreen is MyPlacesScreen)) {
                    Navigator.pop(context);
                    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => MyPlacesScreen()));
                  }
                },
              ),
              decoration: BoxDecoration(
                color: (widget.currScreen is MyPlacesScreen) ? Colors.lightBlueAccent : Colors.white,
              ),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

}
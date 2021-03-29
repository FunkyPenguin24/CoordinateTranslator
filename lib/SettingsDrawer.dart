import 'package:flutter/material.dart';
import 'settingsManager.dart';

class SettingsDrawer extends StatefulWidget {
  final SettingsManager sm;

  SettingsDrawer(this.sm);

  SettingsDrawerState createState() => SettingsDrawerState();

}

class SettingsDrawerState extends State<SettingsDrawer> {

  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80.0,
              child: DrawerHeader(
                child: Text(
                  "Settings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
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

            SettingsBox(title: "Default Lat Long format", key: "Lat/Long type", options: ["Decimal", "Degrees"]),
            Padding(padding: EdgeInsets.only(bottom: 16.0)),

            SettingsBox(title: "Default Grid Ref format", key: "OS type", options: ["Numerical", "Letter"]),
            Padding(padding: EdgeInsets.only(bottom: 16.0)),


          ],
        ),
      ),
    );
  }

  Widget SettingsBox({required String title, required String key, required List<String> options}) {
    return Container(
      height: 80.0,
      child: Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            DropdownButton<String>(
              value: widget.sm.settings[key],
              onChanged: (String? newValue) {
                setState(() {
                  widget.sm.settings[key] = newValue!;
                  widget.sm.saveSettings();
                });
              },
              items: options
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

}
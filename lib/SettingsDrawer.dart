import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';
import 'AppThemes.dart';
import 'settingsManager.dart';

class SettingsDrawer extends StatefulWidget {
  final SettingsManager sm;
  final State parent;

  SettingsDrawer(this.sm, this.parent);

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
              height: 100.0,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                child: Text(
                  "Settings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ), //title

            Container(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Inputs",
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    DropdownSetting(title: "Latitude / Longitude", key: "Lat/Long type", options: ["Decimal", "Degrees"]),

                    DropdownSetting(title: "Grid reference", key: "OS type", options: ["Numerical", "Letter"]),
                  ],
                ),
              ),
            ), //contains the input settings

            Divider(
              thickness: 2.0,
              indent: 50.0,
              endIndent: 50.0,
            ),

            Container(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Outputs",
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SwitchSetting(title: "Easting / Northing", key: "EastingNorthing"),
                    SwitchSetting(title: "Numerical reference", key: "Numerical"),
                    Padding(padding: EdgeInsets.only(bottom: 8.0), child: SwitchSetting(title: "Letter reference", key: "Letter")),
                    DropdownSetting(title: "Latitude / Longitude", key: "Lat/Long output", options: ["Decimal", "Degrees"]),
                    SwitchSetting(title: "What3Words", key: "What3Words"),
                  ],
                ),
              ),
            ), //contains the output settings

            Divider(
              thickness: 2.0,
              indent: 50.0,
              endIndent: 50.0,
            ),

            Container(
              padding: EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Misc",
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "App theme",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          DropdownButton<String>(
                            value: (DynamicTheme.of(context)!.themeId == AppThemes.LIGHT) ? "Light" : "Dark",
                            onChanged: (String? newValue) {
                              switch (newValue) {
                                case "Light":
                                  DynamicTheme.of(context)!.setTheme(AppThemes.LIGHT);
                                  break;
                                case "Dark":
                                  DynamicTheme.of(context)!.setTheme(AppThemes.DARK);
                                  break;
                              }
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: "Light",
                                child: Text("Light"),
                              ),
                              DropdownMenuItem<String>(
                                value: "Dark",
                                child: Text("Dark"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget DropdownSetting({required String title, required String key, required List<String> options}) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
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
                widget.parent.setState(() {
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

  Widget SwitchSetting({required String title, required String key}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
        Switch(
            value: widget.sm.settings[key],
            onChanged: (bool value) {
              widget.parent.setState(() {
                widget.sm.settings[key] = !widget.sm.settings[key];
                widget.sm.saveSettings();
              });
            }
        ),
      ],
    );
  }

}
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
    return WillPopScope(
      onWillPop: () async {
        FocusScope.of(context).unfocus();
        return true;
      },
      child: Container(
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
                  color: Theme.of(context).primaryColor,
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

                      DropdownSetting(title: "Latitude / Longitude", settingsKey: "Lat/Long type", options: ["Decimal", "Degrees"], widget: widget),

                      DropdownSetting(title: "Grid reference", settingsKey: "OS type", options: ["Numerical", "Letter"], widget: widget),
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

                      SwitchSetting(
                          title: "Easting / Northing",
                          settingsKey: "EastingNorthing",
                          widget: widget
                      ),

                      SwitchSetting(
                          title: "Numerical reference",
                          settingsKey: "Numerical",
                          widget: widget
                      ),

                      Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: SwitchSetting(title: "Letter reference",
                              settingsKey: "Letter",
                              widget: widget
                          )
                      ),

                      DropdownSetting(
                          title: "Latitude / Longitude",
                          settingsKey: "Lat/Long output",
                          options: ["Decimal", "Degrees"],
                          widget: widget
                      ),

                      SwitchSetting(
                          title: "What3Words",
                          settingsKey: "What3Words",
                          widget: widget
                      ),
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

                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "Dark theme",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Switch(
                                    value: (DynamicTheme.of(context)!.themeId == AppThemes.DARK),
                                    onChanged: (value) {
                                      if (value) {
                                        DynamicTheme.of(context)!.setTheme(AppThemes.DARK);
                                      } else {
                                        DynamicTheme.of(context)!.setTheme(AppThemes.LIGHT);
                                      }
                                    },
                                  ),
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
      ),
    );
  }

}

class DropdownSetting extends StatelessWidget {

  final String title;
  final String settingsKey;
  final List<String> options;
  final SettingsDrawer widget;

  DropdownSetting({required this.title, required this.settingsKey, required this.options, required this.widget});

  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.0, right: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    enableFeedback: false,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (widget.sm.settings[settingsKey] != options[0]) { //if not already selected
                        widget.parent.setState(() {
                          widget.sm.settings[settingsKey] = options[0];
                          widget.sm.saveSettings();
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      margin: EdgeInsets.only(right: 4.0),
                      child: Text(
                        options[0],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        border: Border.all(
                          width: 3.0,
                          color: (widget.sm.settings[settingsKey] == options[0]) ? Theme.of(context).primaryColorDark : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    enableFeedback: false,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (widget.sm.settings[settingsKey] != options[1]) { //if not already selected
                        widget.parent.setState(() {
                          widget.sm.settings[settingsKey] = options[1];
                          widget.sm.saveSettings();
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      margin: EdgeInsets.only(right: 4.0),
                      child: Text(
                        options[1],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).secondaryHeaderColor,
                        border: Border.all(
                          width: 3.0,
                          color: (widget.sm.settings[settingsKey] == options[1]) ? Theme.of(context).primaryColorDark : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class SwitchSetting extends StatelessWidget {

  final String title;
  final String settingsKey;
  final SettingsDrawer widget;

  SwitchSetting({required this.title, required this.settingsKey, required this.widget});

  Widget build(BuildContext context) {
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
            value: widget.sm.settings[settingsKey],
            onChanged: (bool value) {
              widget.parent.setState(() {
                widget.sm.settings[settingsKey] = !widget.sm.settings[settingsKey];
                widget.sm.saveSettings();
              });
            }
        ),
      ],
    );
  }

}
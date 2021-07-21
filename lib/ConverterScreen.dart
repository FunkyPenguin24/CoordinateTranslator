import 'package:flutter/material.dart';
import 'settingsManager.dart';
import 'SettingsDrawer.dart';
import 'LatLongToOSGB.dart';
import 'OSGBToLatLong.dart';

class ConverterScreen extends StatefulWidget {

  ConverterScreenState createState() => ConverterScreenState();

}

class ConverterScreenState extends State<ConverterScreen> with SingleTickerProviderStateMixin {
  final tabs = ["Lat/Long to OSGB", "OSGB to Lat/Long"];
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  SettingsManager sm = new SettingsManager();
  late TabController tabControl;

  @override
  initState() {
    loadSettings();
    tabControl = new TabController(vsync: this, length: 2);
    tabControl.addListener(() {
      FocusScope.of(context).unfocus();
    });
    super.initState();
  }

  loadSettings() async {
    await sm.checkForFile();
    await sm.loadSettings();
    this.setState(() {
      sm.settings = sm.settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          endDrawer: SettingsDrawer(sm, this),
          endDrawerEnableOpenDragGesture: false,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Coordinate Translator",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            bottom: TabBar(
              controller: tabControl,
              isScrollable: false,
              tabs: [
                for (final tab in tabs) Tab(text: tab),
              ],
              onTap: (index) {
                FocusScope.of(context).unfocus();
                tabControl.animateTo(index);
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _scaffoldKey.currentState!.openEndDrawer();
                },
                icon: Icon(Icons.settings),
              ),
            ],
          ),
          body: TabBarView(
            controller: tabControl,
            children: [
              for (final tab in tabs)
                SingleChildScrollView(
                  child: getTabView(tab),
                ),
            ],
          ),
        )
    );
  }

  Widget? getTabView(String tab) {
    switch (tab) {
      case "Lat/Long to OSGB": return LatLongToOSGB(sm);
      case "OSGB to Lat/Long": return OSGBToLatLong(sm);
      default: return null;
    }
  }

}
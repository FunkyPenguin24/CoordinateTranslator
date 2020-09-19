import 'package:flutter/material.dart';
import 'SideDrawer.dart';
import 'LatLongToOSGB.dart';
import 'OSGBToLatLong.dart';

class ConverterScreen extends StatefulWidget {

  ConverterScreenState createState() => ConverterScreenState();

}

class ConverterScreenState extends State<ConverterScreen> with SingleTickerProviderStateMixin {
  final tabs = ["Lat/Long to OSGB", "OSGB to Lat/Long"];
  TabController tabControl;

  Map<String, String> settings = {
    "Lat/Long type":"Decimal"
  };

  @override
  initState() {
    super.initState();
    tabControl = new TabController(vsync: this, length: 2);
    tabControl.addListener(() {
      if (tabControl.indexIsChanging) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          drawer: SideDrawer(widget),
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Coordinate Translator",
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
          ),
          body: TabBarView(
            //physics: NeverScrollableScrollPhysics(),
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

  Widget getTabView(String tab) {
    switch (tab) {
      case "Lat/Long to OSGB": return LatLongToOSGB(settings); break;
      case "OSGB to Lat/Long": return OSGBToLatLong(settings); break;
    }
  }
}
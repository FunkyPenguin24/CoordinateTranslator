import 'package:flutter/material.dart';
import 'LatLongToOSGB.dart';
import 'OSGBToLatLong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coordinate translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Coordinate Translator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.title,
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

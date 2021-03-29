import 'dart:io';
import 'dart:convert' as convert;
import 'package:path_provider/path_provider.dart';

class SettingsManager {

  Map<String, String> settings = {
    "Lat/Long type":"Decimal",
    "OS type":"Numerical"
  };

  ///if the file does not exists, the program creates it and fills it with the default settings
  checkForFile() async {
    final directory = await getApplicationDocumentsDirectory();
    File sFile = File("${directory.path}/settings.json");
    bool fileExists = await sFile.exists();
    if (!fileExists) {
      await sFile.create();
      await sFile.writeAsString(convert.jsonEncode(settings));
    }
  }

  loadSettings() async {
    final loadDirectory = await getApplicationDocumentsDirectory();
    final file = File("${loadDirectory.path}/settings.json");
    String rawSettings = await file.readAsString();
    if (rawSettings != "") {
      settings = Map.from(convert.jsonDecode(rawSettings));
    }
  }

  saveSettings() async {
    final saveDirectory = await getApplicationDocumentsDirectory();
    final file = File("${saveDirectory.path}/settings.json");
    file.writeAsString(convert.jsonEncode(settings));
  }

}
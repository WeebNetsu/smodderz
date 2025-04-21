import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

/// This contains any of the softwares configurations
class ConfigModel {
  static final File saveFile = File("./config.json");

  // not static we might wanna configure this later
  /// This application regular mods location
  final Directory regularModDirectory = Directory('./mods/regular');

  /// This application logic mods location
  final Directory logicModDirectory = Directory('./mods/logic');
  late Directory _sparkingZeroDirectory;
  late Directory sparkingZeroRegularDir;
  late Directory sparkingZeroLogicDir;

  Directory get sparkingZeroDirectory => _sparkingZeroDirectory;

  set sparkingZeroDirectory(Directory value) {
    _sparkingZeroDirectory = value;

    sparkingZeroRegularDir = Directory(join(_sparkingZeroDirectory.path, "SparkingZERO", "Mods"));
    sparkingZeroLogicDir = Directory(join(_sparkingZeroDirectory.path, "SparkingZERO", "Content", "Paks", "LogicMods"));
  }

  ConfigModel({Directory? sparkingZeroDirectory}) {
    this.sparkingZeroDirectory =
        sparkingZeroDirectory ?? Directory("C:/Program Files (x86)/Steam/steamapps/common/DRAGON BALL Sparking! ZERO");
  }

  Future<bool> saveDataToFile() async {
    try {
      if (!(await saveFile.exists())) await saveFile.create();

      // save user agent and encode all data
      final encodedData = jsonEncode({"sparkingZeroDirectory": sparkingZeroDirectory.path});

      // if the file is empty, don't append , at the start of the json!
      await saveFile.writeAsString(encodedData, mode: FileMode.write);

      return true;
    } catch (err) {
      debugPrint(err.toString());
    }

    return false;
  }

  /// Load config data
  Future<bool> loadDataFromFile() async {
    if (!saveFile.existsSync()) return false;

    final saveData = await saveFile.readAsString();
    dynamic userDataJson;
    try {
      userDataJson = jsonDecode(saveData);
    } on FormatException catch (e) {
      debugPrint(e.toString());

      // if this is the case then our save data is incorrectly formatted and we should redo not a robot check
      return false;
    }

    // not decoding it will leave quotes in the string
    sparkingZeroDirectory = Directory(jsonDecode(userDataJson['sparkingZeroDirectory'].toString()));
    sparkingZeroRegularDir = Directory(join(sparkingZeroDirectory.path, "SparkingZERO", "Mods"));
    sparkingZeroLogicDir = Directory(join(sparkingZeroDirectory.path, "SparkingZERO", "Content", "Paks", "LoicMods"));

    return true;
  }
}

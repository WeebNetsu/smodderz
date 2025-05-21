import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class UserPreferencesModel {
  static const saveFileName = "user_preferences.json";

  /// If true, then debugging logging will be saved
  bool developerMode = false;

  Future<bool> saveToFileData() async {
    try {
      final encodedData = jsonEncode({"developerMode": developerMode});

      final newFile = await File("./$saveFileName").create();

      await newFile.writeAsString(encodedData, mode: FileMode.write);

      return true;
    } catch (err) {
      debugPrint(err.toString());
    }

    return false;
  }

  /// Load data from file, if failed, it will return false
  Future<bool> loadDataFromFile() async {
    final File saveFile = File("./$saveFileName");

    if (!saveFile.existsSync()) {
      await saveToFileData();
      return true;
    }

    final saveData = await saveFile.readAsString();
    final userDataJson = jsonDecode(saveData);

    if (userDataJson['developerMode'] != null) {
      developerMode = userDataJson['developerMode'] == true;
    }

    return true;
  }
}

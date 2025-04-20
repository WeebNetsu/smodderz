import 'dart:io';

/// This defines all the states an item can be in a basket
enum AvailableModTypes {
  /// Regular mods going into the mod folder
  regular,

  /// mods that needs to go into the logic mods folder
  logic,
}

/// contains details about the latest app update
class ModModel {
  final String name;
  final AvailableModTypes modType;
  //   directory/file containing the mod
  final Directory installDir;
  //   if the mod is installed, this will be the install location
  final Directory? outputDir;

  ModModel({required this.modType, required this.name, required this.installDir, this.outputDir});
}

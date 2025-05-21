import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:smodderz/constants/constants.dart';
import 'package:smodderz/models/models.dart';
import 'package:smodderz/theme/theme.dart';
import 'package:smodderz/utils/utils.dart';
import 'package:smodderz/widgets/widgets.dart';

class ModsView extends StatefulWidget {
  const ModsView({super.key});

  // this is so we can easily call the route
  // to this component from other files
  static route() => MaterialPageRoute(builder: (context) => const ModsView());

  @override
  State<ModsView> createState() => _ModsViewState();
}

class _ModsViewState extends State<ModsView> {
  final TextEditingController _modSearch = TextEditingController();
  final _userPreferences = UserPreferencesModel();

  final List<ModModel> _mods = [];
  final _config = ConfigModel();
  //   final logger = FileLogger();

  var logger = Logger(
    output: FileOutput(file: File("./smodderz.log")),
    printer: SimplePrinter(colors: false, printTime: true),
  );
  //   final logger = Logger(output: fileOutput);

  /// list of warnings that should be shown to the user
  final List<String> _warnings = [];

  /// If dragging a file over the regular mods column
  bool _draggingRegularMod = false;

  /// If dragging a file over the logic mods column
  bool _draggingLogicMod = false;

  Future<void> _getMods({BuildContext? context, skipLogs = true}) async {
    if (!skipLogs) logger.d("Getting User Mods");
    setState(() {
      _warnings.clear();
    });

    // create any modding directories if they do not exist
    if (!(await _config.regularModDirectory.exists())) {
      logger.w("${_config.regularModDirectory.path} directory did not exist. Creating.");
      await _config.regularModDirectory.create(recursive: true);
    }

    if (!(await _config.logicModDirectory.exists())) {
      logger.w("${_config.logicModDirectory.path} directory did not exist. Creating.");
      await _config.logicModDirectory.create(recursive: true);
    }

    if (!(await _config.sparkingZeroRegularDir.parent.exists())) {
      if (context != null && context.mounted) {
        logger.e("${_config.sparkingZeroRegularDir.parent.path} does not exist");
        showMessage(context, "Sparking Zero Directory Does Not Exist", error: true);
      }
      return;
    }

    if (!(await _config.sparkingZeroRegularDir.exists())) {
      logger.w("${_config.sparkingZeroRegularDir.path} directory did not exist. Creating.");
      // we can create this if it does not exist
      await _config.sparkingZeroRegularDir.create();
    }

    if (!(await _config.sparkingZeroLogicDir.exists())) {
      logger.w("${_config.sparkingZeroLogicDir.path} directory did not exist. Creating.");
      // we can create this if it does not exist
      await _config.sparkingZeroLogicDir.create();
    }

    final List<ModModel> regularMods =
        await _config.regularModDirectory.list().map((mod) {
          //   final stat = mod.statSync();

          //   if (stat.type == FileSystemEntityType.directory) {
          //     // It's a directory
          //   } else if (stat.type == FileSystemEntityType.file) {
          //     // It's a file
          //   }

          final modName = basename(mod.path);

          final installedMod = Directory(join(_config.sparkingZeroRegularDir.path, modName));

          if (!skipLogs) logger.d("Added $modName to regular mods list");

          return ModModel(
            modType: AvailableModTypes.regular,
            name: modName,
            installDir: Directory(mod.path),
            outputDir: installedMod.existsSync() ? installedMod : null,
          );
        }).toList();

    final List<ModModel> logicMods =
        await _config.logicModDirectory.list().map((mod) {
          final modName = basename(mod.path);

          final installedMod = Directory(join(_config.sparkingZeroLogicDir.path, modName));
          final stat = installedMod.statSync();

          Directory? outputDir;

          if (stat.type == FileSystemEntityType.file) {
            // It's a file
            if (File(installedMod.path).existsSync()) {
              outputDir = installedMod;
            }
          } else {
            if (installedMod.existsSync()) {
              outputDir = installedMod;
            }
          }

          if (!skipLogs) logger.d("Added $modName to logic mods list");

          return ModModel(
            modType: AvailableModTypes.logic,
            name: basename(mod.path),
            installDir: Directory(mod.path),
            outputDir: outputDir,
          );
        }).toList();

    final utocBypassFile = File(
      join(
        _config.sparkingZeroDirectory.path,
        "SparkingZERO",
        "Binaries",
        "Win64",
        "plugins",
        "DBSparkingZeroUTOCBypass.asi",
      ),
    );

    if (!(await utocBypassFile.exists())) {
      logger.w("${utocBypassFile.path} was not found. UTOC Bypass may not be installed");

      setState(() {
        _warnings.add("UTOC Bypass was not found. Some mods may not work.");
      });
    }

    final ue4ssFile = File(join(_config.sparkingZeroDirectory.path, "SparkingZERO", "Binaries", "Win64", "UE4SS.dll"));

    if (!(await ue4ssFile.exists())) {
      logger.w("${ue4ssFile.path} was not found. UE4SS may not be installed");
      setState(() {
        _warnings.add("UE4SS was not found. Some mods may not work.");
      });
    }

    setState(() {
      _mods.clear();
      _mods.addAll([...regularMods, ...logicMods]);
    });
    // if (context.mounted) showMessage(context, "Mods Loaded");

    //     final regularModsDirectory = entities.firstWhere((folderName) => folderName == "mods")

    //     entities.forEach(print);
  }

  Future<void> _installAllMods(BuildContext context, AvailableModTypes modType) async {
    logger.d("Enabling/Disabling all mods for ${modType.toString()}");

    final targetDirectory =
        modType == AvailableModTypes.logic ? _config.sparkingZeroLogicDir : _config.sparkingZeroRegularDir;

    if (!(await targetDirectory.exists())) {
      logger.w("${targetDirectory.path} directory did not exist. Creating.");
      // we can create this if it does not exist
      await targetDirectory.create();
    }

    final selectedMods = _mods.where((mod) => mod.modType == modType);
    final enableMods = selectedMods.firstOrNull?.outputDir == null;
    await Future.wait(
      selectedMods.map((mod) async {
        final statMod = mod.installDir.statSync();

        // if mod is installed
        if (!enableMods) {
          if (statMod.type == FileSystemEntityType.file) {
            logger.d("Disabling ${mod.outputDir!.path} (${statMod.type})");
            if (mod.outputDir != null) await File(mod.outputDir!.path).delete();
          } else if (statMod.type == FileSystemEntityType.directory) {
            logger.d("Disabling ${mod.outputDir!.path} (${statMod.type})");
            if (mod.outputDir != null) await mod.outputDir!.delete(recursive: true);
          } else {
            logger.e("Mod of invalid file type: ${statMod.type}");
            if (context.mounted) showMessage(context, "Mod of invalid file type", error: true);
          }
        } else {
          if (statMod.type == FileSystemEntityType.file) {
            logger.d("Enabling ${mod.installDir.path} (${statMod.type} - ${mod.installDir.path})");
            await File(mod.installDir.path).copy(join(targetDirectory.path, basename(mod.installDir.path)));
          } else if (statMod.type == FileSystemEntityType.directory) {
            logger.d("Enabling ${mod.installDir.path} (${statMod.type} - ${mod.installDir.path})");
            await copyDirectory(mod.installDir, Directory(join(targetDirectory.path, mod.name)));
          } else {
            logger.e("Mod of invalid file type: ${statMod.type} (${mod.name} - ${mod.installDir.path})");
            if (context.mounted) showMessage(context, "Mod of invalid file type", error: true);
          }
        }
      }).toList(),
    );

    if (context.mounted) {
      //   showMessage(context, "Mod Added");
      await _getMods(context: context);
    }
  }

  /// Install or uninstall mod
  ///
  /// Passing in explicit remove will force only removal or installation (if false - null by default) of a mod
  Future<void> _importMod(BuildContext context, DropItem file, AvailableModTypes modType) async {
    logger.d("Installing singular mod from drag/drop to $modType");

    final targetDirectory =
        modType == AvailableModTypes.logic ? _config.logicModDirectory : _config.regularModDirectory;

    if (!(await targetDirectory.exists())) {
      // we can create this if it does not exist
      await targetDirectory.create();
    }

    // if mod is installed
    if (await FileSystemEntity.isFile(file.path)) {
      logger.d("Installing (file) ${file.path} to ${targetDirectory.path}");
      await File(file.path).copy(join(targetDirectory.path, basename(file.path)));
    } else if (await FileSystemEntity.isDirectory(file.path)) {
      logger.d("Installing (directory) ${file.path} to ${targetDirectory.path}");
      await copyDirectory(Directory(file.path), Directory(join(targetDirectory.path, file.name)));
    } else {
      logger.e("Mod of invalid file type: ${file.path}");

      if (context.mounted) showMessage(context, "Mod of invalid file type", error: true);
    }

    if (context.mounted) {
      showMessage(context, "Mods Added");
      await _getMods(context: context);
    }
  }

  /// Install or uninstall mod
  ///
  /// Passing in explicit remove will force only removal or installation (if false - null by default) of a mod
  Future<void> _installMod(BuildContext context, ModModel mod, {bool? explicitRemove}) async {
    logger.d("Installing/Removing singular mod");

    final targetDirectory =
        mod.modType == AvailableModTypes.logic ? _config.sparkingZeroLogicDir : _config.sparkingZeroRegularDir;

    if (!(await targetDirectory.exists())) {
      logger.w("${targetDirectory.path} directory did not exist. Creating.");
      // we can create this if it does not exist
      await targetDirectory.create();
    }

    final statMod = mod.installDir.statSync();

    final List<ModModel> linkedMods = [];
    // if mod name is .pak there are 2 other files that are linked to it
    // which we hide for convenience
    if (mod.name.endsWith('.pak') && explicitRemove == null) {
      linkedMods.addAll(
        _mods.where((selectedMod) {
          // other paks are not related
          if (selectedMod.name.endsWith(".pak")) return false;

          return selectedMod.name.replaceAll(".utoc", "").replaceAll(".ucas", "") == mod.name.replaceAll(".pak", "");
        }),
      );
    }

    // if mod is installed
    if (mod.outputDir != null) {
      if (explicitRemove == false) return;
      logger.d("Deleting mod from SZ install directory (${statMod.type}) ${mod.outputDir?.path}");
      if (statMod.type == FileSystemEntityType.file) {
        await File(mod.outputDir!.path).delete();

        for (var linkedMod in linkedMods) {
          logger.d("Removing linked mod");
          if (context.mounted) await _installMod(context, linkedMod, explicitRemove: true);
        }
      } else if (statMod.type == FileSystemEntityType.directory) {
        await mod.outputDir!.delete(recursive: true);
      } else {
        logger.w("Mod of invalid file type ${statMod.type} (${mod.installDir})");

        if (context.mounted) showMessage(context, "Mod of invalid file type", error: true);
      }
    } else {
      if (explicitRemove == true) return;
      logger.d("Installing mod (${statMod.type}) ${mod.installDir.path}");

      if (statMod.type == FileSystemEntityType.file) {
        await File(mod.installDir.path).copy(join(targetDirectory.path, basename(mod.installDir.path)));

        for (var linkedMod in linkedMods) {
          logger.d("Installing linked mod");
          if (context.mounted) await _installMod(context, linkedMod, explicitRemove: false);
        }
      } else if (statMod.type == FileSystemEntityType.directory) {
        await copyDirectory(mod.installDir, Directory(join(targetDirectory.path, mod.name)));
      } else {
        logger.w("Mod of invalid file type ${statMod.type} (${mod.installDir})");

        if (context.mounted) showMessage(context, "Mod of invalid file type", error: true);
      }
    }

    if (context.mounted) {
      // explicit removal will only apply to mods that are not visible to the user
      //   a null state for explicitRemove will allow a refresh
      if (explicitRemove == true || explicitRemove == false) return;
      //   showMessage(context, "Mod Added");
      await _getMods(context: context);
    }
  }

  Future<void> _getSparkingZeroDirectory(BuildContext context) async {
    logger.d("Getting sparking zero directory");
    String? path = await FilePicker.platform.getDirectoryPath();

    // the user closed the dialogue
    if (path == null) return;

    final newDir = Directory(path);

    if (!(await newDir.exists())) {
      logger.e("${newDir.path} directory does not exist.");
      if (context.mounted) showMessage(context, "Chosen directory does not exist", error: true);
      return;
    }

    _config.sparkingZeroDirectory = newDir;
    logger.i("Saving Sparking Zero Directory as ${newDir.path}");
    await _config.saveDataToFile();
  }

  Future<void> _loadUserPreferences() async {
    logger.d("Loading user preferences");
    await _userPreferences.loadDataFromFile();

    logger = Logger(
      output: FileOutput(file: File("./smodderz.log")),
      printer: SimplePrinter(colors: false, printTime: true),
      level: _userPreferences.developerMode ? Level.all : Level.warning,
    );
  }

  Future<void> _loadData() async {
    logger.d("Loading mod page data");
    await _loadUserPreferences();
    await _config.loadDataFromFile();
    await _getMods(skipLogs: false);
  }

  void _onSearchChanged() {
    // this empty set state will trigger a refresh when search changes
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadData();

    _modSearch.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _modSearch.removeListener(_onSearchChanged);
    _modSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regularMods =
        _mods.where((mod) => mod.modType == AvailableModTypes.regular).where((mod) {
          if (_modSearch.text.isEmpty) return true;

          return mod.name.toLowerCase().contains(_modSearch.text.toLowerCase());
        }).toList();

    final logicMods =
        _mods
            .where((mod) => mod.modType == AvailableModTypes.logic)
            //   only show pak mods for convenience
            .where((mod) => !mod.name.endsWith(".utoc") && !mod.name.endsWith(".ucas"))
            .where((mod) {
              if (_modSearch.text.isEmpty) return true;

              return mod.name.toLowerCase().contains(_modSearch.text.toLowerCase());
            })
            .toList();

    logicMods.sort((a, b) => a.name.compareTo(b.name));
    regularMods.sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text("Install Path: ${_config.sparkingZeroDirectory.path}"),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text("Set Installation Path"),
                    onPressed: () => _getSparkingZeroDirectory(context),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    child: Text("Check Mods"),
                    onPressed: () => _getMods(context: context, skipLogs: false),
                  ),
                  _warnings.isNotEmpty
                      ? Tooltip(message: _warnings.join("\n"), child: Icon(Icons.info, color: Colors.yellow))
                      : Container(),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _modSearch,
                      decoration: InputDecoration(hintText: 'Search Mods'),
                      onChanged: (_) => _onSearchChanged(),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await Navigator.pushNamed(context, AppRoutes.settings);
                      //   fetch any new settings that were applied
                      await _loadUserPreferences();
                    },
                    icon: Icon(Icons.settings),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropTarget(
                    onDragDone: (detail) async {
                      for (final file in detail.files) {
                        await _importMod(context, file, AvailableModTypes.regular);
                      }
                      //   setState(() {
                      //     // _list.addAll(detail.files);
                      //     print(detail.files.first.path);
                      //   });
                    },
                    onDragEntered: (detail) {
                      setState(() {
                        _draggingRegularMod = true;
                      });
                    },
                    onDragExited: (detail) {
                      setState(() {
                        _draggingRegularMod = false;
                      });
                    },
                    child: Container(
                      color: _draggingRegularMod ? Colors.blue.withValues(alpha: 0.4) : Palette.backgroundColor,
                      child:
                          regularMods.isEmpty
                              ? const Center(child: Text("Drop here"))
                              : Column(
                                children: [
                                  Text("Regular Mods", style: TextStyle(fontSize: 30)),
                                  SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: SizedBox(
                                      width: 400,
                                      child: ElevatedButton(
                                        onPressed: () => _installAllMods(context, AvailableModTypes.regular),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(255, 241, 238, 34),
                                        ),
                                        child: Text(
                                          "Enable/Disable All",
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),

                                  ...regularMods.map(
                                    (mod) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: SizedBox(
                                        width: 400,
                                        child: EnabledButtonWidget(
                                          text: mod.name,
                                          onClick: () => _installMod(context, mod),
                                          enabled: mod.outputDir != null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  DropTarget(
                    onDragDone: (detail) async {
                      for (final file in detail.files) {
                        await _importMod(context, file, AvailableModTypes.logic);
                      }
                      //   setState(() {
                      //     // _list.addAll(detail.files);
                      //     print(detail.files.first.path);
                      //   });
                    },
                    onDragEntered: (detail) {
                      setState(() {
                        _draggingLogicMod = true;
                      });
                    },
                    onDragExited: (detail) {
                      setState(() {
                        _draggingLogicMod = false;
                      });
                    },
                    child: Container(
                      color: _draggingLogicMod ? Colors.blue.withValues(alpha: 0.4) : Palette.backgroundColor,
                      child:
                          logicMods.isEmpty
                              ? const Center(child: Text("Drop here"))
                              : Column(
                                children: [
                                  Text("Logic Mods", style: TextStyle(fontSize: 30)),
                                  SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: SizedBox(
                                      width: 400,
                                      child: ElevatedButton(
                                        onPressed: () => _installAllMods(context, AvailableModTypes.logic),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color.fromARGB(255, 241, 238, 34),
                                        ),
                                        child: Text(
                                          "Enable/Disable All",
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...logicMods.map(
                                    (mod) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: SizedBox(
                                        width: 400,
                                        child: EnabledButtonWidget(
                                          text: mod.name,
                                          onClick: () => _installMod(context, mod),
                                          enabled: mod.outputDir != null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

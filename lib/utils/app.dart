import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Get the directory that your app has access to as file storage
Future<Directory?> getAppDir() async {
  var dirs = await getExternalStorageDirectories();
  if (dirs == null || dirs.isEmpty) return null;

  return dirs[0];
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  if (!await destination.exists()) {
    await destination.create(recursive: true);
  }

  await for (var entity in source.list(recursive: false)) {
    if (entity is Directory) {
      var newDir = Directory(join(destination.path, basename(entity.path)));
      await copyDirectory(entity, newDir);
    } else if (entity is File) {
      var newFile = File(join(destination.path, basename(entity.path)));
      await newFile.writeAsBytes(await entity.readAsBytes());
    }
  }
}

/// Count number of files in a directory
int countFilesInDirectory(Directory directory) {
  if (!directory.existsSync()) {
    throw ArgumentError('Directory does not exist: ${directory.path}');
  }

  int count = 0;

  for (var fileEntity in directory.listSync()) {
    if (fileEntity is File) count++;
  }

  return count;
}

/// Get the size of your cache directory (may not be 100% same as in app info page)
Future<int> getCacheSize() async {
  Directory tempDir = await getTemporaryDirectory();
  int tempDirSize = getDirectorySize(tempDir);
  return tempDirSize;
}

/// Get the size of your cache directory (may not be 100% same as in app info page)
Future<int> getDownloadsSize() async {
  final Directory? appDir = await getAppDir();
  if (appDir == null) return 0;
  final int appDirSize = getDirectorySize(appDir);
  return appDirSize;
}

/// Get the size of a directory
int getDirectorySize(FileSystemEntity file) {
  if (file is File) {
    return file.lengthSync();
  } else if (file is Directory) {
    int sum = 0;
    List<FileSystemEntity> children = file.listSync();
    for (FileSystemEntity child in children) {
      sum += getDirectorySize(child);
    }
    return sum;
  }
  return 0;
}

// Future<void> openUrl(String url) async {
//   final uri = Uri.parse(url);
//   if (await canLaunchUrl(uri)) await launchUrl(uri);
// }

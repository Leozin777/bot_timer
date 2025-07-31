import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileStorage {
  static final FileStorage _instance = FileStorage._internal();

  factory FileStorage() => _instance;

  FileStorage._internal();

  Future<Directory> get _appDocumentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  Future<Directory> getCustomDirectory(String folderName) async {
    final Directory appDir = await _appDocumentsDirectory;
    final Directory customDir = Directory(path.join(appDir.path, folderName));

    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }

    return customDir;
  }

  Future<File> saveFile({required String folderName, required String fileName, required String content}) async {
    final dir = await getCustomDirectory(folderName);
    final File file = File(path.join(dir.path, fileName));
    return await file.writeAsString(content);
  }

  Future<String> readFile(String folderName, String fileName) async {
    try {
      final dir = await getCustomDirectory(folderName);
      final File file = File(path.join(dir.path, fileName));

      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<List<FileSystemEntity>> listFiles(String folderName) async {
    final dir = await getCustomDirectory(folderName);
    return dir.listSync();
  }

  Future<bool> fileExists(String folderName, String fileName) async {
    final dir = await getCustomDirectory(folderName);
    final File file = File(path.join(dir.path, fileName));
    return await file.exists();
  }

  Future<void> deleteFile(String folderName, String fileName) async {
    final dir = await getCustomDirectory(folderName);
    final File file = File(path.join(dir.path, fileName));

    if (await file.exists()) {
      await file.delete();
    }
  }
}

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as ppv;

class ThikDb {
  final String tableName;
  late final Box box;
  static const String valuesSeparator = "‡";

  ThikDb(this.tableName);

  /// Set [dbDirName] if you want this package handle Hive init
  /// Set [aesKey] if you want to encrypt your table by [HiveAesCipher]
  /// Return full path of database directory
  /// if this package handle [Hive.init()], or else return null
  Future<String?> open({String dbDirName = "", List<int>? aesKey}) async {
    String? dbDirPath;

    /// Save database into app's storage directory
    if(dbDirName.isNotEmpty) {
      List<String> appPathList = await listAppDirectory();

      if(appPathList.isEmpty) {
        throw FileSystemException("OS ${Platform.operatingSystem} not handled.");
      }
      dbDirPath = path.join(appPathList[0], dbDirName);
      Hive.init(dbDirPath);
    }
    HiveCipher? cipher;
    if(aesKey != null) {
      cipher = HiveAesCipher(aesKey);
    }
    box = await Hive.openBox(tableName, encryptionCipher: cipher);
    return dbDirPath;
  }

  T get<T>(String key, T defaultValue) {
    if(T == Alignment) {
      String? strValue = box.get(key);
      if(strValue == null) {
        return defaultValue;
      }
      return stringToAlign(strValue) as T;
    }
    return box.get(key, defaultValue: defaultValue) as T;
  }

  void put<T>(String key, T value) {
    if(T == Alignment) {
      box.put(key, alignToString(value as Alignment));
      return;
    }
    box.put(key, value);
  }

  Future<void> close() async {
    await box.flush();
    await box.compact();
    await box.close();
  }

  /// As [Alignment] is not primitive type, parse it to String
  static String alignToString(Alignment value) {
    return "${value.x}${ThikDb.valuesSeparator}${value.y}";
  }
  static Alignment stringToAlign(String dbValue) {
    List<double> ret = dbValue.split(ThikDb.valuesSeparator)
        .map((e) => double.parse(e)).toList();
    return Alignment(ret[0], ret[1]);
  }

  Future<List<String>> listAppDirectory() async {
    if(Platform.isWindows){
      return <String>[File(Platform.resolvedExecutable).parent.path];
    }
    if(Platform.isAndroid){
      List<Directory>? externalStorageDirectories = await ppv.getExternalStorageDirectories();
      if(null == externalStorageDirectories) {
        throw const FileSystemException("Cannot get externalStorageDirectories on android!");
      }
      return externalStorageDirectories.map((e) => e.path).toList();
    }

    return <String>[];
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as ppv;

class StringDb {
  final String tableName;
  late final Box<String> box;
  static const String stringJoinSeparator = "‡";

  StringDb(this.tableName);

  //Set dbRootDir if Hive is not init before
  Future<void> open({String dbRootDir = "", List<int>? aesKey}) async {
    if(dbRootDir.isNotEmpty) {
      String dbDirPath = "";
      if(Platform.isWindows){
        dbDirPath = path.join(File(Platform.resolvedExecutable).parent.path, dbRootDir);
      }
      if(Platform.isAndroid){
        List<Directory>? externalStorageDirectories = await ppv.getExternalStorageDirectories();
        if(null == externalStorageDirectories) {
          throw const FileSystemException("Cannot get externalStorageDirectories on android!");
        }
        dbDirPath = path.join(externalStorageDirectories[0].path, dbRootDir);
      }

      if(dbDirPath.isEmpty) {
        throw FileSystemException("OS ${Platform.operatingSystem} not handled.");
      }
      Hive.init(dbDirPath);
    }
    HiveCipher? cipher;
    if(aesKey != null) {
      cipher = HiveAesCipher(aesKey);
    }
    box = await Hive.openBox<String>(tableName, encryptionCipher: cipher);
  }

  Future<void> close() async {
    await box.flush();
    await box.compact();
    await box.close();
  }

  void put<T>(String key, T value) {
    bool handled = true;
    String dbValue = "";
    switch(T) {
      case String:
      case int:
      case double:
      case Alignment:
        dbValue = "$value";
        break;
      case bool:
        box.put(key, (value as bool) ? "1" : "0");
        break;
      default:
        handled = false;
        break;
    }
    if(handled) {
      box.put(key, dbValue);
      return;
    }

    if(T.toString().startsWith("List")) {
      if((value as List).isEmpty){dbValue = "";}
      dbValue = value.join(stringJoinSeparator);
    } else if(T.toString().startsWith("Map")) {
      dbValue = jsonEncode(value);
    } else {
      dbValue = "$value";
    }
    box.put(key, dbValue);
  }

  void del(String key) {
    box.delete(key);
  }

  T get<T>(String key, T defaultValue) {
    String? text = box.get(key);
    if(null == text){
      return defaultValue;
    }
    if(T == String) {
      return (text as T) ?? defaultValue;
    }
    if(T == int) {
      return int.parse(text) as T;
    }
    if(T == double) {
      return double.parse(text) as T;
    }
    if(T == Alignment) {
      return parseAlign(text) as T;
    }
    if(T == bool) {
      return ("1" == text) as T;
    }
    if(T.toString().startsWith("List")) {
      List<String> ret = <String>[];
      if(text.isEmpty){return ret as T;}

      ret.addAll(text.split(stringJoinSeparator));
      return ret as T;
    }
    if(T.toString().startsWith("Map")) {
      Map<String, dynamic> ret = {};
      if(text.isEmpty){return ret as T;}

      ret = jsonDecode(text);
      return ret as T;
    }
    return null as T;
  }

  static Alignment parseAlign(String? alignStr){
    if(alignStr== null || alignStr.isEmpty){return Alignment.center;}
    if(alignStr== Alignment.topLeft.toString()) {return Alignment.topLeft;}
    if(alignStr== Alignment.topCenter.toString()) {return Alignment.topCenter;}
    if(alignStr== Alignment.topRight.toString()) {return Alignment.topRight;}
    if(alignStr== Alignment.centerLeft.toString()) {return Alignment.centerLeft;}
    if(alignStr== Alignment.centerRight.toString()) {return Alignment.centerRight;}
    if(alignStr== Alignment.center.toString()) {return Alignment.center;}
    if(alignStr== Alignment.bottomLeft.toString()) {return Alignment.bottomLeft;}
    if(alignStr== Alignment.bottomCenter.toString()) {return Alignment.bottomCenter;}
    if(alignStr== Alignment.bottomRight.toString()) {return Alignment.bottomRight;}
    if(!alignStr.contains(",")){return Alignment.center;}
    List<String> alignStrSplited= alignStr.substring(
        alignStr.indexOf("(") + 1, alignStr.length- 1).split(",");
    return Alignment(double.parse(alignStrSplited[0]), double.parse(alignStrSplited[1]));
  }
}
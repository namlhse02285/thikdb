import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thikdb/thikdb.dart';

void main() {
  test('adds one to input values', () async {
    await AppConfig.init();
    assert(AppConfig.dbPath.isNotEmpty);

    TestDb testDb = TestDb("test_box");
    await testDb.open();
    await testDb.put("key-1", "val-1");
    assert(testDb.box.isNotEmpty);
    await testDb.close();
  });
}

class AppConfig extends ThikDb {
  static const String dbDir = "db_test_dir";
  static late final AppConfig _;
  AppConfig() :super("app_config");

  static Future<void> init() async {
    _ = AppConfig();
    String dbFullPath = (await _.open(initDirName: dbDir))!;
    dbPath = dbFullPath;
  }

  static String get testStringVar => _.get("testStringVar", "");
  static set testStringVar(String value) => _.put("testStringVar", value);

  static double get testDoubleVar => _.get("testDoubleVar", 0.0);
  static set testDoubleVar(double value) => _.put("testDoubleVar", value);

  static List<double> get testListVar => _.get("testListVar", <double>[]);
  static set testListVar(List<double> value) => _.put("testListVar", value);

  static Map get testMapVar => _.get("testMapVar", {});
  static set testMapVar(Map value) => _.put("testMapVar", value);

  static Alignment get testAlignVar => _.get("testAlignVar", Alignment.center);
  static set testAlignVar(Alignment value) => _.put("testAlignVar", value);

  static String get dbPath => _.get("dbPath", "");
  static set dbPath(String value) => _.put("dbPath", value);

  static String? get testNullableVar => _.box.get("testNullableVar");
  static set testNullableVar(String? value) => null == value
      ? _.box.delete("testNullableVar") : _.box.put("testNullableVar", value);
}

class TestDb extends ThikDb {
  TestDb(super.tableName);

  @override
  Future<String?> open(
      {String initDirName = "", List<int>? aesKey, String boxSubDir = ""}) {
    return super.open(boxSubDir: "dir_for_test_box");
  }
}
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thikdb/thikdb.dart';

void main() {
  test('adds one to input values', () async {
    AppConfig.init().whenComplete(() {
      assert(AppConfig.dbPath.isNotEmpty);
    });
  });
}

class AppConfig extends ThikDb {
  static const String dbDir = "db";
  static late final AppConfig _;
  AppConfig() :super("app_config");

  static Future<void> init() async {
    _ = AppConfig();
    String dbFullPath = (await _.open(dbDirName: dbDir))!;
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
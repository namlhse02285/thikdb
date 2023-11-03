import 'package:flutter_test/flutter_test.dart';

import 'package:thikdb/thikdb.dart';

void main() {
  test('adds one to input values', () async {
    await AppConfig.init();
    AppConfig.o.testVar = "test value";
  });
}

class AppConfig extends StringDb {
  static late AppConfig _instance;
  AppConfig() :super("app_config");
  static AppConfig get o => _instance;

  static Future<void> init() async {
    _instance = AppConfig();
    await _instance.open();
  }

  String get testVar => box.get("testVar") ?? "";
  set testVar(String value) => box.put("testVar", value);
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart' as ppv;
import 'package:thikdb/thikdb.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint(Directory.current.path);
  AppConfig.init().whenComplete(() {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThikDb demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SafeArea(child: Material(child: AppWg())),
    );
  }
}

class AppWg extends StatelessWidget {
  const AppWg({super.key});

  @override
  Widget build(BuildContext context) {
    AppCtl ctl = Get.put(AppCtl());
    return Column(children: [
      Text(AppConfig.dbPath),
      Obx(() => Text(ctl.testStringVar.value)),
      ElevatedButton(onPressed: () {
        AppConfig.testStringVar = AppConfig.testStringVar.isEmpty ? "not_empty" : "";
        ctl.testStringVar.value = AppConfig.testStringVar;
      }, child: const Text("testStringVar")),
      Obx(() => Text(ctl.testDoubleVar.toString())),
      ElevatedButton(onPressed: () {
        AppConfig.testDoubleVar = AppConfig.testDoubleVar == 0.0 ? 1.2 : 0.0;
        ctl.testDoubleVar.value = AppConfig.testDoubleVar;
      }, child: const Text("testDoubleVar")),
      Obx(() => Text(ctl.testListVar.toString())),
      ElevatedButton(onPressed: () {
        AppConfig.testListVar = AppConfig.testListVar.isEmpty ? <double>[0,1,2,3] : <double>[];
        ctl.testListVar.value = AppConfig.testListVar;
      }, child: const Text("testListVar")),
      Obx(() => Text(ctl.testMapVar.toString())),
      ElevatedButton(onPressed: () {
        AppConfig.testMapVar = AppConfig.testMapVar.isEmpty ? {"A": 1, "b": 3} : {};
        ctl.testMapVar.value = AppConfig.testMapVar;
      }, child: const Text("testMapVar")),
      Obx(() => Text(ctl.testAlignVar.toString())),
      ElevatedButton(onPressed: () {
        AppConfig.testAlignVar = AppConfig.testAlignVar== Alignment.center ? Alignment.bottomLeft : Alignment.center;
        ctl.testAlignVar.value = AppConfig.testAlignVar;
      }, child: const Text("testAlignVar")),
      Obx(() => Text(ctl.testNullableVar.toString())),
      ElevatedButton(onPressed: () {
        AppConfig.testNullableVar = AppConfig.testNullableVar== null ? "not_null" : null;
        ctl.testNullableVar.value = AppConfig.testNullableVar;
      }, child: const Text("testNullableVar")),
      ElevatedButton(onPressed: () {
        AppConfig._.close().whenComplete(() {
          SystemNavigator.pop();
        });
      }, child: const Text("Close and exit")),
    ],);
  }
}

class AppCtl extends GetxController {
  RxString testStringVar = RxString(AppConfig.testStringVar);
  RxDouble testDoubleVar = RxDouble(AppConfig.testDoubleVar);
  RxList<double> testListVar = RxList<double>(AppConfig.testListVar);
  RxMap testMapVar = RxMap(AppConfig.testMapVar);
  Rx<Alignment> testAlignVar = Rx<Alignment>(AppConfig.testAlignVar);
  RxnString testNullableVar = RxnString(AppConfig.testNullableVar);
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
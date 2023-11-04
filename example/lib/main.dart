import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart' as ppv;
import 'package:thikdb/thikdb.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      Obx(() => Text(ctl.testStringVar.value)),
      ElevatedButton(onPressed: () {
        AppConfig.testStringVar = AppConfig.testStringVar.isEmpty ? "not_empty" : "";
        ctl.testStringVar.value = AppConfig.testStringVar;
      }, child: const Text("testStringVar")),
    ],);
  }
}

class AppCtl extends GetxController {
  RxString testStringVar = RxString(AppConfig.testStringVar);
  RxDouble testDoubleVar = RxDouble(AppConfig.testDoubleVar);
}

class AppConfig extends StringDb {
  static const String dbRootDir = "db";
  static late AppConfig _;
  AppConfig() :super("app_config");

  static Future<void> init() async {
    _ = AppConfig();
    await _.open(dbRootDir);
  }

  static String get testStringVar => _.get("testStringVar", "");
  static set testStringVar(String value) => _.put("testStringVar", value);

  static double get testDoubleVar => _.get("testDoubleVar", 0.0);
  static set testDoubleVar(double value) => _.put("testDoubleVar", value);

  static String? get testNullableVar => _.box.get("testNullableVar");
  static set testNullableVar(String? value) => null == value
    ? _.box.delete("testNullableVar") : _.box.put("testNullableVar", value);
}
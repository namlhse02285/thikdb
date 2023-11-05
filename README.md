Hive implementation for easy create simple config for app.

## Features

- Quick implement config (ex: for app) with data save to Hive db

## Getting started

Create class that extend ThikDb then call open()
For example:
```dart
class AppConfig extends ThikDb {
  static const String dbDir = "db"; //create 'db' directory under app directory
  static late final AppConfig _; //static instance to quick access
  AppConfig() :super("app_config"); //db table name

  static Future<void> init() async {
    _ = AppConfig();
    String dbFullPath = (await _.open(dbDirName: dbDir))!;
    dbPath = dbFullPath;
  }
}
```

## Usage

Create some static variable that you will directly access.
Longer examples is in `/example` folder.

```dart
static String get testStringVar => _.get("testStringVar", ""); //key - default value
static set testStringVar(String value) => _.put("testStringVar", value); //key - value
```

call listAppDirectory() to get simple app folder for some goal, ex: for save big file

## Additional information

Either create issue on Github or email me if you found something or want more info

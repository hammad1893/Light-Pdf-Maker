import 'package:hive/hive.dart';

part 'setting_model.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String defaultFileName;

  @HiveField(1)
  String quality;

  @HiveField(2)
  String saveLocation;

  SettingsModel({
    required this.defaultFileName,
    required this.quality,
    required this.saveLocation,
  });
}

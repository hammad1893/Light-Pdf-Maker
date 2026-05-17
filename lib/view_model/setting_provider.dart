import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:small_pdf_maker_/model/setting_model.dart';

final settingsBoxProvider = Provider<Box<SettingsModel>>((ref) {
  return Hive.box<SettingsModel>('settings');
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel?>((ref) {
  final box = ref.watch(settingsBoxProvider);

  if (box.isEmpty) {
    // first time → set defaults
    return SettingsNotifier(box);
  } else {
    return SettingsNotifier(box, box.get('user'));
  }
});

class SettingsNotifier extends StateNotifier<SettingsModel?> {
  final Box<SettingsModel> box;

  SettingsNotifier(this.box, [SettingsModel? state]) : super(state) {
    _initDefaultPath();
  }

  Future<void> _initDefaultPath() async {
    if (state == null) {
      Directory dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final defaultSettings = SettingsModel(
        defaultFileName: "PDF_DOC_",
        quality: "150 DPI",
        saveLocation: dir.path,
      );
      box.put('user', defaultSettings);
      state = defaultSettings;
    }
  }

  void updateFileName(String newName) {
    final updated = SettingsModel(
      defaultFileName: newName,
      quality: state?.quality ?? "150 DPI",
      saveLocation: state!.saveLocation,
    );
    box.put('user', updated);
    state = updated;
  }

  void updateQuality(String newQuality) {
    final updated = SettingsModel(
      defaultFileName: state?.defaultFileName ?? "PDF_DOC_",
      quality: newQuality,
      saveLocation: state!.saveLocation,
    );
    box.put('user', updated);
    state = updated;
  }

  void updateSaveLocation(String newLocation) {
    final updated = SettingsModel(
      defaultFileName: state?.defaultFileName ?? "PDF_DOC_",
      quality: state?.quality ?? "150 DPI",
      saveLocation: newLocation,
    );
    box.put('user', updated);
    state = updated;
  }
}

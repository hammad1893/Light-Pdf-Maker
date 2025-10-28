import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:small_pdf_maker_/model/setting_model.dart';

final settingsBoxProvider = Provider<Box<SettingsModel>>((ref) {
  return Hive.box<SettingsModel>('settings');
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel?>((ref) {
      final box = ref.watch(settingsBoxProvider);

      if (box.isEmpty) {
        // first time → set defaults
        final defaultSettings = SettingsModel(
          defaultFileName: "PDF_DOC_",
          quality: "150 DPI ",
          saveLocation: "/storage/emulated/0/Documents",
        );
        box.put('user', defaultSettings);
        return SettingsNotifier(box, defaultSettings);
      } else {
        return SettingsNotifier(box, box.get('user'));
      }
    });

class SettingsNotifier extends StateNotifier<SettingsModel?> {
  final Box<SettingsModel> box;

  SettingsNotifier(this.box, SettingsModel? state) : super(state);

  void updateFileName(String newName) {
    final updated = SettingsModel(
      defaultFileName: newName,
      quality: state?.quality ?? "150 DPI",
      saveLocation: state?.saveLocation ?? "/storage/emulated/0/Documents",
    );
    box.put('user', updated);
    state = updated;
  }

  void updateQuality(String newQuality) {
    final updated = SettingsModel(
      defaultFileName: state?.defaultFileName ?? "PDF_DOC_",
      quality: newQuality,
      saveLocation: state?.saveLocation ?? "/storage/emulated/0/Documents",
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

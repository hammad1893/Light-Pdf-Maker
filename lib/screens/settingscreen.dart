import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:small_pdf_maker_/constants/colors.dart';
import 'package:small_pdf_maker_/constants/text.dart';
import 'package:small_pdf_maker_/provider/setting_provider.dart';

class Settingscreen extends ConsumerStatefulWidget {
  const Settingscreen({super.key});

  @override
  ConsumerState<Settingscreen> createState() => _SettingscreenState();
}

class _SettingscreenState extends ConsumerState<Settingscreen> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Appcolors.secondaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.06),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: Appcolors.headingColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: size.width * 0.05),
                  Text("Settings", style: Apptext.headingtext),
                ],
              ),
              SizedBox(height: size.height * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text("PDF Settings", style: Apptext.subheading)],
              ),
              SizedBox(height: size.height * 0.02),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.037,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Appcolors.lightgreyColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PDF Quality", style: Apptext.subheading2),
                    Text(
                      "Choose the output resolution for your generated PDFs Files",
                      style: Apptext.bodygreymedium,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        isActive
                            ? PopupMenuButton<String>(
                              color: Appcolors.lightgreyColor,
                              initialValue: settings!.quality,
                              onSelected: (value) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateQuality(value);
                              },
                              itemBuilder:
                                  (context) => const [
                                    PopupMenuItem(
                                      value: "Low (72 DPI)",
                                      child: Text("Low (72 DPI)"),
                                    ),
                                    PopupMenuItem(
                                      value: "Medium (150 DPI)",
                                      child: Text("Medium (150 DPI)"),
                                    ),
                                    PopupMenuItem(
                                      value: "High (300 DPI)",
                                      child: Text("High (300 DPI)"),
                                    ),
                                  ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Appcolors.buttonColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      settings.quality,
                                      style: Apptext.subheading2.copyWith(
                                        color: Appcolors.buttonColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down,
                                      size: 26,
                                      color: Appcolors.buttonColor,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : GestureDetector(
                              onTap: () {
                                setState(() {
                                  isActive = true; 
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Appcolors.subHeadingColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Medium (150 DPI)",
                                      style: Apptext.subheading2.copyWith(
                                        color: Appcolors.subHeadingColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.02),

              Container(
                height: size.height * 0.15,
                width: size.width * 0.9,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.037),
                decoration: BoxDecoration(
                  color: Appcolors.lightgreyColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.008),
                    Text("Default Filename", style: Apptext.subheading2),
                    Text(
                      "Text added before auto-generated filenames",
                      style: Apptext.bodygreymedium,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            final newName = await _showInputDialog(
                              context,
                              "Default Filename",
                              settings.defaultFileName,
                            );
                            if (newName != null && newName.isNotEmpty) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateFileName(newName);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Appcolors.lightgreyColor,
                            minimumSize: const Size(80, 46),
                            side: const BorderSide(
                              width: 1.5,
                              color: Appcolors.subHeadingColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            settings!.defaultFileName,
                            style: Apptext.subheading2.copyWith(
                              color: Appcolors.subHeadingColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),

              Container(
                height: size.height * 0.15,
                width: size.width * 0.9,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.037),
                decoration: BoxDecoration(
                  color: Appcolors.lightgreyColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.008),
                    Text("Default Save Location", style: Apptext.subheading2),
                    Text(
                      "Choose the default folder to save generated PDFs.",
                      style: Apptext.bodygreymedium,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: size.width * 0.65,
                          child: OutlinedButton(
                            onPressed: () async {
                              final newLocation = await _showInputDialog(
                                context,
                                "Save Location",
                                settings.saveLocation,
                              );
                              if (newLocation != null &&
                                  newLocation.isNotEmpty) {
                                ref
                                    .read(settingsProvider.notifier)
                                    .updateSaveLocation(newLocation);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Appcolors.lightgreyColor,
                              minimumSize: const Size(80, 46),
                              side: BorderSide(
                                width: 1.5,
                                color: Appcolors.subHeadingColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              settings.saveLocation,
                              style: Apptext.subheading2.copyWith(
                                color: Appcolors.subHeadingColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showInputDialog(
    BuildContext context,
    String title,
    String currentValue,
  ) async {
    final controller = TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        Size size = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Appcolors.secondaryColor,
          title: Text(title, style: Apptext.subheading),
          content: TextField(
            autofocus: true,
            style: Apptext.bodygreybold.copyWith(color: Appcolors.headingColor),
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter value",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Appcolors.buttonColor),
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(08),
                  side: BorderSide(color: Appcolors.buttonColor),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: Apptext.bodygreybold.copyWith(
                  color: Appcolors.buttonColor,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(08),
                ),
              ),
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(
                "Save",
                style: Apptext.bodygreybold.copyWith(
                  color: Appcolors.secondaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

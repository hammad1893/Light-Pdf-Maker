import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:small_pdf_maker_/constants/colors.dart';
import 'package:small_pdf_maker_/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/constants/text.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  // Cache device info
  AndroidDeviceInfo? _androidInfo;
  int? _sdkInt;

  /// Initialize device info (call this once at app startup)
  Future<void> initialize() async {
    if (Platform.isAndroid) {
      _androidInfo = await DeviceInfoPlugin().androidInfo;
      _sdkInt = _androidInfo!.version.sdkInt;
    }
  }

  /// Get Android SDK version
  int get androidSdkVersion {
    if (!Platform.isAndroid) return 0;
    return _sdkInt ?? 0;
  }

  /// Android 13+ check
  bool get isAndroid13OrAbove => androidSdkVersion >= 33;

  /// Android 11+ check
  bool get isAndroid11OrAbove => androidSdkVersion >= 30;

  /// Main method to request all necessary permissions
  static Future<Map<PermissionType, bool>> requestAllPermissions(
    BuildContext context,
  ) async {
    final manager = PermissionManager();
    await manager.initialize();

    final results = <PermissionType, bool>{};

    // Only essential permissions
    results[PermissionType.storage] = await manager._requestStoragePermission(
      context,
    );

    results[PermissionType.camera] = await manager._requestCameraPermission(
      context,
    );

    results[PermissionType.gallery] = await manager._requestGalleryPermission(
      context,
    );

    return results;
  }

  /// Unified single permission request
  Future<bool> _requestSinglePermission({
    required BuildContext context,
    required Permission permission,
    required String permissionName,
  }) async {
    try {
      final status = await permission.request();

      switch (status) {
        case PermissionStatus.granted:
          return true;

        case PermissionStatus.denied:
          SnackbarMessage.error(context, "$permissionName denied ❌");
          return false;

        case PermissionStatus.permanentlyDenied:
          _showPermissionDialog(context, permissionName);
          return false;

        case PermissionStatus.restricted:
          SnackbarMessage.error(context, "$permissionName restricted 🔒");
          return false;

        case PermissionStatus.limited:
          // No info snackbar here, just treat as granted
          return true;

        default:
          return false;
      }
    } catch (e) {
      SnackbarMessage.error(context, "Error requesting $permissionName");
      return false;
    }
  }

  /// Storage Permission Handler
  Future<bool> _requestStoragePermission(BuildContext context) async {
    if (Platform.isIOS) {
      return await _requestSinglePermission(
        context: context,
        permission: Permission.photos,
        permissionName: "Photos",
      );
    }

    if (isAndroid13OrAbove) {
      // ✅ Android 13+ (only Photos)
      return await _requestSinglePermission(
        context: context,
        permission: Permission.photos,
        permissionName: "Photos",
      );
    } else if (isAndroid11OrAbove) {
      // ✅ Android 11-12 (Manage Storage)
      return await _requestSinglePermission(
        context: context,
        permission: Permission.manageExternalStorage,
        permissionName: "Manage Storage",
      );
    } else {
      // ✅ Android 6-10 (Storage)
      return await _requestSinglePermission(
        context: context,
        permission: Permission.storage,
        permissionName: "Storage",
      );
    }
  }

  /// Camera Permission Handler
  Future<bool> _requestCameraPermission(BuildContext context) async {
    final cameraGranted = await _requestSinglePermission(
      context: context,
      permission: Permission.camera,
      permissionName: "Camera",
    );

    if (!cameraGranted) return false;

    // Also ask Photos (for saving captured images)
    if (Platform.isAndroid) {
      if (isAndroid13OrAbove) {
        await _requestSinglePermission(
          context: context,
          permission: Permission.photos,
          permissionName: "Photos",
        );
      } else {
        await _requestSinglePermission(
          context: context,
          permission: Permission.storage,
          permissionName: "Storage",
        );
      }
    } else if (Platform.isIOS) {
      await _requestSinglePermission(
        context: context,
        permission: Permission.photos,
        permissionName: "Photos",
      );
    }
    return true;
  }

  /// Gallery Permission Handler
  Future<bool> _requestGalleryPermission(BuildContext context) async {
    if (Platform.isIOS) {
      return await _requestSinglePermission(
        context: context,
        permission: Permission.photos,
        permissionName: "Photos",
      );
    }

    if (isAndroid13OrAbove) {
      return await _requestSinglePermission(
        context: context,
        permission: Permission.photos,
        permissionName: "Gallery",
      );
    } else {
      return await _requestSinglePermission(
        context: context,
        permission: Permission.storage,
        permissionName: "Gallery",
      );
    }
  }

  /// Check essential permissions only
  static Future<bool> hasAllEssentialPermissions() async {
    final manager = PermissionManager();
    await manager.initialize();

    if (Platform.isAndroid) {
      if (manager.isAndroid13OrAbove) {
        return await Permission.photos.isGranted &&
            await Permission.camera.isGranted;
      } else if (manager.isAndroid11OrAbove) {
        return await Permission.manageExternalStorage.isGranted &&
            await Permission.camera.isGranted;
      } else {
        return await Permission.storage.isGranted &&
            await Permission.camera.isGranted;
      }
    } else {
      return await Permission.photos.isGranted &&
          await Permission.camera.isGranted;
    }
  }

  /// Open settings
  static Future<void> openAppSettingsPage(BuildContext context) async {
    final opened = await openAppSettings();
    if (!opened) {
      SnackbarMessage.error(context, "Cannot open settings");
    }
  }

  /// Show dialog for permanently denied
  void _showPermissionDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,

      builder:
          (_) => AlertDialog(
            backgroundColor: Appcolors.secondaryColor,
            title: Text(
              "$permissionName Permission Required",
              style: Apptext.subheading2,
            ),
            content: Text(
              "This feature requires $permissionName access. "
              "Please enable it in your device settings to continue.",
              style: Apptext.bodygreymedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Not Now",
                  style: TextStyle(color: Appcolors.subHeadingColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettingsPage(context);
                },
                child: Text(
                  "Open Settings",
                  style: TextStyle(color: Appcolors.buttonColor),
                ),
              ),
            ],
          ),
    );
  }
}

/// Allowed Permission Types
enum PermissionType { storage, camera, gallery }

/// Utility class
class QuickPermissionUtils {
  static Future<bool> checkGalleryPermission(BuildContext context) async {
    final manager = PermissionManager();
    await manager.initialize();
    return await manager._requestGalleryPermission(context);
  }

  static Future<bool> checkCameraPermission(BuildContext context) async {
    final manager = PermissionManager();
    await manager.initialize();
    return await manager._requestCameraPermission(context);
  }

  static Future<bool> checkStoragePermission(BuildContext context) async {
    final manager = PermissionManager();
    await manager.initialize();
    return await manager._requestStoragePermission(context);
  }
}

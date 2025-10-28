import 'package:flutter/material.dart';
import 'package:small_pdf_maker_/constants/back_button_handler.dart';
import 'package:small_pdf_maker_/constants/colors.dart';
import 'package:small_pdf_maker_/constants/file_picker_utils.dart';
import 'package:small_pdf_maker_/constants/permission_utils.dart';
import 'package:small_pdf_maker_/constants/snackbarmessage.dart';
import 'package:small_pdf_maker_/screens/favoritepdfsaver.dart';
import 'package:small_pdf_maker_/screens/homescreen.dart';
import 'package:small_pdf_maker_/screens/recentpdfsaver.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _selectedIndex = 0;

  final List<Widget> screens = const [
    Homescreen(),
    Recentpdfsaver(),
    Favoritepdfsaver(),
  ];

  // Track if we've shown permission dialog for this session
  bool _hasShownPermissionDialog = false;

  @override
  void initState() {
    super.initState();
    _checkEssentialPermissions();
  }

  // Check permissions when app starts (but don't block navigation)
  Future<void> _checkEssentialPermissions() async {
    await Future.delayed(const Duration(seconds: 1)); 

    final hasAllPermissions =
        await PermissionManager.hasAllEssentialPermissions();

    if (!hasAllPermissions && !_hasShownPermissionDialog) {
      _hasShownPermissionDialog = true;
      _showPermissionRecommendation();
    }
  }

  void _showPermissionRecommendation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder:
            (context) => AlertDialog(
              title: const Text("Enable Permissions for Full Features"),
              content: const Text(
                "To use all features like camera, gallery access, and file management, "
                "please grant the required permissions. You can do this now or later in settings.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Later"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _requestPermissionsNow();
                  },
                  child: const Text("Enable Now"),
                ),
              ],
            ),
      );
    });
  }

  Future<void> _requestPermissionsNow() async {
    final results = await PermissionManager.requestAllPermissions(context);

    if (results[PermissionType.storage]! && results[PermissionType.camera]!) {
      await FilePickerUtils.openFilePicker(context);
    }
  }

  Future<void> _onFabPressed() async {
    final hasStoragePermission =
        await QuickPermissionUtils.checkStoragePermission(context);

    if (!hasStoragePermission) {
      SnackbarMessage.error(
        context,
        "Storage permission required to access files",
      );
      return;
    }

    FilePickerUtils.openFilePicker(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => BackButtonHandler.handleBackButton(context),
      child: Scaffold(
        backgroundColor: Appcolors.secondaryColor,
        body: screens[_selectedIndex],

        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedIndex,
          onItemTapped: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Appcolors.buttonColor,
          shape: const CircleBorder(),
          onPressed: _onFabPressed,
          child: Icon(Icons.add, color: Appcolors.secondaryColor, size: 30),
        ),
      ),
    );
  }
}

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 20),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.folder_outlined, 1),
            _buildNavItem(Icons.star_border_outlined, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Appcolors.buttonColor : Appcolors.subHeadingColor,
        ),
      ),
    );
  }
}
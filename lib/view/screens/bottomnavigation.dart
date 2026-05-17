import 'package:flutter/material.dart';
import 'package:small_pdf_maker_/view/constants/back_button_handler.dart';
import 'package:small_pdf_maker_/view/constants/colors.dart';
import 'package:small_pdf_maker_/view/constants/file_picker_utils.dart';
import 'package:small_pdf_maker_/view/screens/favoritepdfsaver.dart';
import 'package:small_pdf_maker_/view/screens/homescreen.dart';
import 'package:small_pdf_maker_/view/screens/recentpdfsaver.dart';

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

  Future<void> _onFabPressed() async {
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

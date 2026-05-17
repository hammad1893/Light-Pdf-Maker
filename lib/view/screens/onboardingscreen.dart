import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:small_pdf_maker_/view/constants/colors.dart';
import 'package:small_pdf_maker_/view/constants/text.dart';
import 'package:small_pdf_maker_/view/screens/bottomnavigation.dart';
import 'package:small_pdf_maker_/view/widgets/customelevatedbutton.dart';

class Onboradingscreen extends StatefulWidget {
  const Onboradingscreen({super.key});

  @override
  State<Onboradingscreen> createState() => _OnboradingscreenState();
}

class _OnboradingscreenState extends State<Onboradingscreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> splashData = [
    {
      "image": "assets/images/onboard1.svg",
      "title": "Instant PDF Creation",
      "desc": "Create, merge, and share PDFs in just a few taps",
    },
    {
      "image": "assets/images/onboard3.svg",
      "title": "Stay Organized",
      "desc": "Keep All Your PDFs in One Place",
    },
    {
      "image": "assets/images/onboard2.svg",
      "title": "Share with Ease",
      "desc": "Create & Share Anywhere",
    },
  ];
  void nextPage() {
    if (_currentPage < splashData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Appcolors.secondaryColor,
      body: Column(
        children: [
          SizedBox(height: size.height * .15),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: splashData.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder:
                  (context, index) => Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          splashData[index]['image']!,
                          height: size.height * .3,
                        ),
                        SizedBox(height: size.height * .135),
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * .03),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(splashData.length, (index) {
                              bool isActive = _currentPage == index;
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color:
                                      isActive
                                          ? Appcolors.buttonColor
                                          : Color(0xffd9d9d9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: size.height * .017),
                        Text(
                          splashData[index]['title']!,
                          style: TextStyle(
                            fontSize: size.width * .065,
                            fontWeight: FontWeight.w600,
                            color: Appcolors.headingColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * .012),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            splashData[index]['desc']!,
                            softWrap: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: size.width * .034,
                              fontWeight: FontWeight.w400,
                              color: Appcolors.subHeadingColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.height * .04),
            child: SizedBox(
              height: size.height * .069,
              width: double.infinity,
              child: Customelevatedbutton(
                title:
                    _currentPage < splashData.length - 1
                        ? "Next"
                        : "Get Started",
                onTap: () {
                  if (_currentPage < splashData.length - 1) {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainHome()),
                    );
                  }
                },
              ),
            ),
          ),
          SizedBox(height: size.height * .015),
          if (_currentPage < splashData.length - 1) ...{
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainHome()),
                );
              },
              child: Text(
                "Skip",
                style: Apptext.bodygreybold.copyWith(
                  color: Appcolors.subHeadingColor,
                ),
              ),
            ),
          },
          SizedBox(height: size.height * .03),
        ],
      ),
    );
  }
}

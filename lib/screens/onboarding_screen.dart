import 'package:amazing_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const routeName = "OnboardingScreen";

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late Material materialButton;
  late int index;

  _storeOnboard() async {
    bool isViewed = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('viewed_onboard', isViewed);
  }

  final onboardingPagesList = [
    PageModel(
      widget: SingleChildScrollView(
        controller: ScrollController(),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20, left: 80, right: 80),
                child: SizedBox(
                  height: 250,
                  width: 150,
                  child: Image.asset('assets/images/protection.png'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 45, left: 30, right: 30),
                child: Text(
                  'Encrypt your files!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
    PageModel(
      widget: SingleChildScrollView(
        controller: ScrollController(),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20, left: 80, right: 80),
                child: SizedBox(
                  height: 250,
                  width: 150,
                  child: Image.asset('assets/images/google-drive.png'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 45, left: 30, right: 30),
                child: Text(
                  'Upload to Google Drive!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
    PageModel(
      widget: SingleChildScrollView(
        controller: ScrollController(),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 200,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20, left: 80, right: 80),
                child: SizedBox(
                  height: 250,
                  width: 150,
                  child: Image.asset('assets/images/face.png'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 45, left: 30, right: 30),
                child: Text(
                  'Access with facial recognition!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    materialButton = _skipButton();
    index = 0;
  }

  Material get _signupButton {
    return Material(
      borderRadius: defaultProceedButtonBorderRadius,
      color: defaultProceedButtonColor,
      child: InkWell(
        borderRadius: defaultProceedButtonBorderRadius,
        onTap: () async {
          await _storeOnboard();
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        },
        child: const Padding(
          padding: defaultProceedButtonPadding,
          child: Text(
            'Sign up',
            style: defaultProceedButtonTextStyle,
          ),
        ),
      ),
    );
  }

  Material _skipButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: defaultSkipButtonColor,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          if (setIndex != null) {
            index = 2;
            setIndex(2);
          }
        },
        child: const Padding(
          padding: defaultSkipButtonPadding,
          child: Text(
            'Skip',
            style: defaultSkipButtonTextStyle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Onboarding(
          pages: onboardingPagesList,
          onPageChange: (int pageIndex) {
            index = pageIndex;
          },
          startPageIndex: 0,
          footerBuilder: (context, dragDistance, pagesLength, setIndex) {
            return DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.0,
                  color: Colors.white,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(45.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomIndicator(
                      netDragPercent: dragDistance,
                      pagesLength: pagesLength,
                      indicator: Indicator(
                        indicatorDesign: IndicatorDesign.line(
                          lineDesign: LineDesign(
                            lineWidth: 25,
                            lineType: DesignType.line_uniform,
                          ),
                        ),
                      ),
                    ),
                    index == pagesLength - 1
                        ? _signupButton
                        : _skipButton(setIndex: setIndex)
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

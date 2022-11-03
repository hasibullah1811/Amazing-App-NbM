import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
int _pageIndex = 0;
late PageController _pageController;
bool button = false;

class _OnboardingScreenState extends State<OnboardingScreen> {

  @override
  void initState(){
    _pageController = PageController(initialPage: 0);
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: demo_data.length,
                  controller: _pageController,
                  onPageChanged: (index){
                    setState(() {
                      _pageIndex = index;

                    });index==3? button = true: false; index<3?button=false:true;
                  },
                  itemBuilder:(context, index) => OnBoardContent(
                    image: demo_data[index].image,
                    title: demo_data[index].title,
                    description: demo_data[index].description,
                  ),
                ),
              ),
              Row(
                children: [
                  ...List.generate(demo_data.length,
                          (index) => Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: DotIndicator(isActive: index == _pageIndex),
                      )
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: button? ElevatedButton(
                      onPressed: () {_pageController.nextPage(curve: Curves.ease, duration: const Duration(microseconds: 300));
                        },
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          shadowColor: Colors.deepPurple),
                      child: Image.asset("assets/pictures/rar.jpg", height: 50,
                      ),
                    ): null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
class DotIndicator extends StatelessWidget {
  const DotIndicator({Key? key,
    this.isActive = false,
  }) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.black.withOpacity(0.4),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
class Onboard{
  final String image, title, description;

  Onboard({
    required this.image,
    required this.title,
    required this.description,
  });
}
final List<Onboard> demo_data = [
  Onboard(
      image: "assets/pictures/trees.png",
      title: "Welcome to Amazing App",
      description: "Swipe left",
  ),
  Onboard(
      image: "assets/pictures/upfiles.jpg",
      title: "Upload Files",
      description: "Your uploaded files will be saved to your google drive",
  ),
  Onboard(
      image: "assets/pictures/security.png",
      title: "Your Data is Secured",
      description: "With anti-spoofing feature, no one else can have access to your files",
  ),
  Onboard(
    image: "assets/pictures/go.jpg",
    title: "Get Started !",
    description: "",
  ),
];

class OnBoardContent extends StatelessWidget {
  const OnBoardContent({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String image, title, description;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(image, height: 400,
        ),

        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
            color: Colors.cyan[600],
            fontFamily: 'DancingScript',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
            fontFamily: 'DancingScript',
          ),
        )
      ],
    );
  }
}






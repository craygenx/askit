import 'package:askit/ServiceOptions.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  bool _isLastPage = false;
  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (int page) {
              setState(() {
                _isLastPage = page == 2;
              });
            },
            children: [
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .65,
                          height: MediaQuery.of(context).size.height * .35,
                          child: Image.asset(
                            'assets/resolution/Frame-1.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          child: const Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Text(
                                  'Verified Service Provider',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              Text(
                                'From walking your dog, to fixing broken pipes in your bathroom '
                                'we have verified Service providers who can help with it all. '
                                'Post any task for free.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .65,
                          height: MediaQuery.of(context).size.height * .35,
                          child: Image.asset(
                            'assets/resolution/Frame-2.png',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          child: const Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Text(
                                  'Select from the best',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              Text(
                                'Verified Service providers will bid on your task. Choose '
                                'among the top rated Service providers',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .65,
                          height: MediaQuery.of(context).size.height * .35,
                          child: Image.asset(
                            'assets/resolution/Frame-3.png',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          child: const Column(
                            children: [
                              Text(
                                'Get it done!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Text(
                                  'Pay them securely',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              Text(
                                'After the task is completed review and release the payment,'
                                'funds are held by us securely until the task is completed',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Container(
              alignment: const Alignment(0, 0.75),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                        width: MediaQuery.of(context).size.width * .65,
                        alignment: const Alignment(0, 0),
                        child: SmoothPageIndicator(
                          controller: _controller,
                          count: 3,
                          effect: const WormEffect(
                            dotWidth: 10.0,
                            dotHeight: 10.0,
                            activeDotColor: Colors.white,
                            dotColor: Colors.grey,
                          ),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isLastPage) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ServiceOptions()));
                      } else {
                        _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .8,
                      height: 50,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white),
                      child: Center(
                        child: Text(
                          _isLastPage ? 'Done' : 'Next',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
      title: const Text(
        'Getting Started',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ServiceOptions()));
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ))
      ],
    );
  }
}

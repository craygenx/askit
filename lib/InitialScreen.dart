import 'package:askit/Login.dart';
import 'package:askit/OnBoardingScreen.dart';
import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //replace with the logo image
              SizedBox(
                height: 50,
                width: 50,
                child: Image.asset(
                  'assets/logo/Group 2461.png',
                  width: MediaQuery.of(context).size.width * .6,
                  height: 40,
                ),
              ),
              //replace with image
              SizedBox(
                height: MediaQuery.of(context).size.height * .35,
                width: MediaQuery.of(context).size.width * .65,
                child: Image.asset(
                  'assets/resolution/Frame.png',
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .65,
                child: const Text(
                  'Describe your task, Review your '
                  'offers & choose a service provider '
                  'best for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFA7A7A7),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login()));
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const OnBoardingScreen()));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .8,
                            height: 50,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.white),
                            child: const Center(
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

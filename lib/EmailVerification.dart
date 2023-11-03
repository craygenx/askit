import 'dart:async';

import 'package:askit/Homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlutterEmailVerification extends StatelessWidget {
  final String? email;
  const FlutterEmailVerification({Key? key, this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    void showToastMessage(String message, Color textColor) =>
        Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.amberAccent,
          textColor: textColor,
          fontSize: 16,
        );

    void autoRedirectTimer(){
      Timer.periodic(const Duration(seconds: 3), (timer){
        auth.currentUser?.reload();
        final user = auth.currentUser;
        if(user!.emailVerified){
          timer.cancel();
          showToastMessage('Email verified', Colors.white);
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const Homepage()));
        }
      });
    }

    autoRedirectTimer();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: SizedBox(
                height: 100,
                width: 100,
                child: Placeholder(),
              ),
            ),
            const Text('Email Confirmation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 10.0),
            //   child: SizedBox(
            //     width: MediaQuery.of(context).size.width * .80,
            //     child: const Text('We have sent an email to testemail@gmail.com for verification. '
            //         ' After receiving the email follow the link provided to complete registration.',
            //       textAlign: TextAlign.center,
            //       style: TextStyle(
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .80,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: 'We have sent an email to ',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    children: <TextSpan>[
                      TextSpan(
                          text: email,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const TextSpan(
                        text: ' for verification. After receiving the email follow the link provided to complete registration.'
                      )
                    ]
                  )
                ),
              ),
            ),
            GestureDetector(
              child: const Text('Resend email',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}

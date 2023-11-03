import 'dart:async';

import 'package:askit/EmailVerification.dart';
import 'package:askit/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Homepage.dart';


class SignUp extends StatefulWidget {
  final String serviceType;
  const SignUp({required this.serviceType, Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  String emailErrorMsg = '';
  String passErrorMsg = '';
  String lastNameErrorMsg = '';
  String firstNameErrorMsg = '';
  String errorMessage = '';
  bool passError = false;
  bool mailError = false;
  bool lastError = false;
  bool firstError = false;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  IconData _passwordIcon = Icons.visibility;
  bool _isLoading = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
      _passwordIcon = _obscureText ? Icons.visibility : Icons.visibility_off;
    });
  }

  void showToastMessage(String message, Color textColor)=> Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.TOP,
    toastLength: Toast.LENGTH_SHORT,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.amberAccent,
    textColor: textColor,
    fontSize: 16,
  );

  Future<void> _signUp() async{
    setState(() {
      passError = false;
      passErrorMsg = '';
      mailError = false;
      emailErrorMsg = '';
      firstError = false;
      firstNameErrorMsg = '';
      lastNameErrorMsg = '';
      lastError = false;
    });
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    if(fcmToken == null) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        User? user = userCredential.user;
        if(user != null ){
          await user.updateDisplayName(_firstName.text);
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': _firstName.text,
          'lastName': _lastName.text,
          'email': _emailController.text,
          'serviceType': widget.serviceType,
          'fcmToken': fcmToken,
        });

        // Registration successful, perform any additional actions
        // Navigator.push(context, MaterialPageRoute(builder: (context)=> const Homepage()));
        //_showSnackBar(context, 'SignUp Successful', Colors.green);
        showToastMessage('Sign Up Successful', Colors.green);
        sendEmailVerification();
        Navigator.push(context, MaterialPageRoute(builder: (context)=> FlutterEmailVerification(email: _emailController.text,)));
      } catch (error) {
        // Handle re
        //_showSnackBar(context, 'Error occurred', Colors.red);
        showToastMessage('Error occurred', Colors.red);
      }finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void> sendEmailVerification() async{
    try{
      await auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch(e){
      showToastMessage(e.toString(), Colors.white);
      // final ex = TExceptions.fromCode(e.code);
      // throw ex.message;
    }catch(_){
      showToastMessage("Error occurred", Colors.white);
      // const ex = TExceptions();
      // throw ex.message;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ), onPressed: (){
            Navigator.pop(context);
        },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: (){},
            child: const Text('Already have an account?',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const Login()));
            },
            child: const Text('Sign in',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ]
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Sign Up',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,

              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: errorMessage.isNotEmpty,
                      child: Text(errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(10),
                              border: firstError ? Border.all(
                                color: Colors.red,
                              ) : Border.all(
                                color: Colors.transparent,
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: TextFormField(
                              controller: _firstName,
                              style: const TextStyle(
                                  color: Colors.white
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  setState(() {
                                    firstError = true;
                                    firstNameErrorMsg = 'Please enter your first name';
                                    errorMessage = 'Please enter your first name';
                                  });
                                  setState(() {
                                    firstNameErrorMsg = '';
                                  });
                                  return null;
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 8.0),
                                  border: InputBorder.none,
                                hintText: 'First Name',
                                  hintStyle: TextStyle(
                                      color: Colors.grey
                                  )
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(10),
                                border: lastError ? Border.all(
                              color: Colors.red,
                              ) : Border.all(
                              color: Colors.transparent,
                            ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: TextFormField(
                              controller: _lastName,
                              style: const TextStyle(
                                  color: Colors.white
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  setState(() {
                                    lastNameErrorMsg = 'Please enter your last name';
                                    lastError = true;
                                    errorMessage = 'Please enter your last name';
                                  });
                                  setState(() {
                                    lastNameErrorMsg = '';
                                  });
                                  return null;
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 8.0),
                                border: InputBorder.none,
                                hintText: 'Last Name',
                                hintStyle: TextStyle(
                                      color: Colors.grey
                                  )
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(10),
                          border: mailError ? Border.all(
                            color: Colors.red,
                          ) : Border.all(
                            color: Colors.transparent,
                          ),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.white
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              setState(() {
                                mailError = true;
                                emailErrorMsg = 'Please enter your email';
                                errorMessage = 'Please enter your email';
                              });
                              return null;
                            }
                            if (!value.contains('@')) {
                              setState(() {
                                mailError = true;
                                emailErrorMsg = 'Please enter your email';
                                errorMessage = 'Please enter a valid email address';
                              });
                              return null;
                            }
                            setState(() {
                              mailError = false;
                              emailErrorMsg = '';
                            });
                            return null;
                          },
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 8.0),
                            border: InputBorder.none,
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(
                                  color: Colors.grey
                              )
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(10),
                          border: passError ? Border.all(
                            color: Colors.red,
                          ) : Border.all(
                            color: Colors.transparent,
                          ),
                        ),
                        child: TextFormField(
                          obscureText: _obscureText,
                          controller: _passwordController,
                          style: const TextStyle(
                              color: Colors.white
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              setState(() {
                                passError = true;
                                errorMessage = 'Please enter a password';
                              });
                              return null;
                            }
                            if (!RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$')
                                .hasMatch(value)) {
                              setState(() {
                                passError = true;
                                passErrorMsg = 'Must contain at least 8 characters("Az""1-0") and a symbol';
                                errorMessage = 'Must contain at least 8 characters("Az""1-0") and a symbol';
                              });
                              return null;
                            }
                            setState(() {
                              passError = false;
                              passErrorMsg = '';
                            });
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 8.0, top: 8.0),
                            suffixIcon: IconButton(
                                onPressed: (){
                                  _togglePasswordVisibility();
                                },
                                icon: Icon(_passwordIcon,
                                  color: Colors.white30,
                                ),
                            ),
                            border: InputBorder.none,
                            hintText: 'Set password',
                              hintStyle: const TextStyle(
                                  color: Colors.grey
                              )
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: GestureDetector(
                        onTap: () async{
                          errorMessage = '';
                          _signUp();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: 50,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: _isLoading ? const CircularProgressIndicator() : const Text('Join Askit',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),
            const Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Divider(
                      color: Colors.white,
                      thickness: 1.0,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Divider(
                      color: Colors.white,
                      thickness: 1.0,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: GestureDetector(
                      onTap: (){
                        // try {
                        //   final LoginResult result = await FacebookAuth.instance.login();
                        //
                        //   if (result.status == LoginStatus.success) {
                        //     final AccessToken accessToken = result.accessToken!;
                        //
                        //     final AuthCredential credential =
                        //     FacebookAuthProvider.credential(accessToken.token);
                        //
                        //     await FirebaseAuth.instance.signInWithCredential(credential);
                        //
                        //     // Sign-up with Facebook successful, perform any additional actions
                        //     // or navigate to another screen.
                        //     print('Signed up with Facebook successfully!');
                        //   } else if (result.status == LoginStatus.cancelled) {
                        //     // User cancelled the Facebook sign-in.
                        //     print('Facebook sign-in cancelled by user.');
                        //   } else {
                        //     // Error occurred during Facebook sign-in.
                        //     print('Error signing up with Facebook: ${result.message}');
                        //   }
                        // } catch (error) {
                        //   // Handle any errors during the sign-up process.
                        //   print('Error signing up with Facebook: $error');
                        // }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * .8,
                        height: 50,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color.fromRGBO(24, 119, 242, 1),//RGB(24, 119, 242)
                        ),
                        child: const Center(
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20.0, right: 20),
                                child: Icon(Icons.facebook,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              Text('Continue with Facebook',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      // try {
                      //   final GoogleSignIn googleSignIn = GoogleSignIn();
                      //   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
                      //
                      //   if (googleUser != null) {
                      //     final GoogleSignInAuthentication googleAuth =
                      //         await googleUser.authentication;
                      //
                      //     final AuthCredential credential = GoogleAuthProvider.credential(
                      //       idToken: googleAuth.idToken,
                      //       accessToken: googleAuth.accessToken,
                      //     );
                      //
                      //     await FirebaseAuth.instance.signInWithCredential(credential);
                      //
                      //     // Sign-up with Google successful, perform any additional actions
                      //     // or navigate to another screen.
                      //     print('Signed up with Google successfully!');
                      //   } else {
                      //     // User cancelled the Google sign-in.
                      //     print('Google sign-in cancelled by user.');
                      //   }
                      // } catch (error) {
                      //   // Handle any errors during the sign-up process.
                      //   print('Error signing up with Google: $error');
                      // }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .8,
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0, right: 20),
                              child: Image.asset('assets/g1.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                            const Text('Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .8,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'By clicking Join askit, Continue with Facebook or Google, you agree to our ',
                        //style: DefaultTextStyle.of(context).style,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFA7A7A7)
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Terms & Conditions ',
                              style: const TextStyle(
                                color: Colors.white
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = (){}
                          ),
                          const TextSpan(
                            text: 'and ',
                          ),
                          TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                  color: Colors.white
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = (){}
                          ),
                        ]
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

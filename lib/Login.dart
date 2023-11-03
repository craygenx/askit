import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Homepage.dart';
import 'ServiceOptions.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  IconData _passwordIcon = Icons.visibility;
  bool _isLoading = false;
  bool _error= false;
  bool _passError = false;
  bool _mailError = false;

  // Future<String> getAppVersion() async{
  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   return packageInfo.version;
  // }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
      _passwordIcon = _obscureText ? Icons.visibility : Icons.visibility_off;
    });
  }

  void _showSnackBar(BuildContext context, String text, Color color){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          height: 50,
          alignment: Alignment.center,
          child: Text(text,
            style: TextStyle(
              color: color,
            ),
          ),
        ),
        backgroundColor: Colors.white30,
        duration: const Duration(seconds: 2),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showToastMessage(String message, Color textColor)=> Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.TOP,
    toastLength: Toast.LENGTH_LONG,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.grey,
    textColor: textColor,
    fontSize: 16,
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
              onPressed: (){},
              child: const Text('New User?',
                style: TextStyle(
                  color: Color(0xFFA7A7A7),
                ),
              ),
          ),
          TextButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const ServiceOptions()));
              },
              child: const Text('Sign Up',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                      visible: _error,
                        child: const Text("Incorrect email or password, please try again",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10),
                          border: _mailError ? Border.all(
                            color: Colors.red,
                          ) : Border.all(
                            color: Colors.transparent,
                          )
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
                                _error = true;
                                _mailError=true;
                              });
                              return null;
                            }
                            if (!value.contains('@')) {
                              setState(() {
                                _error = true;
                                _mailError=true;
                              });
                              return null;
                            }
                            setState(() {
                              _error = false;
                              _mailError=false;
                            });
                            return null;
                          },
                          decoration: const InputDecoration(
                              contentPadding: EdgeInsets.only(left: 8.0),
                            border: InputBorder.none,
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                              )
                            ),
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
                            border: _passError ? Border.all(
                              color: Colors.red,
                            ) : Border.all(
                              color: Colors.transparent,
                            ),
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(10)
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
                                _error = true;
                                _passError = true;
                              });
                              return null;
                            }
                            setState(() {
                              _error = false;
                              _passError = true;
                            });
                            return null;
                          },
                          decoration: InputDecoration(
                              errorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                  )
                              ),
                              contentPadding: const EdgeInsets.only(left: 8.0, top: 8),
                              suffixIcon: IconButton(
                                  onPressed: (){
                                    _togglePasswordVisibility();
                                  },
                                  icon: Icon(_passwordIcon,
                                    color: Colors.white30,
                                  ),
                              ),
                              border: InputBorder.none,
                              hintText: 'Enter password',
                              hintStyle: const TextStyle(
                                  color: Colors.grey
                              )
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: (){},
                            child: const Text('Forgot Password?',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async{
                        setState(() {
                          _mailError = false;
                          _passError = false;
                          _error = false;
                        });
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            if(userCredential.user != null){
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setBool('loggedInKey', true);
                            }

                            // Login successful, perform any additional actions
                            // or navigate to another screen.
                            //_showSnackBar(context, 'LogIn Successful', Colors.green);
                            showToastMessage('Log In successful', Colors.white);
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> const Homepage()));
                          } catch (error) {
                            // Handle login errors
                            //_showSnackBar(context, 'Error occurred', Colors.red);
                            showToastMessage('Error occurred', Colors.red);
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: 50,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                        ),
                        child: Center(
                          child: _isLoading ? const CircularProgressIndicator() : const Text('Log In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: GestureDetector(
                        onTap: (){
                          // try {
                          //   final LoginResult result = await FacebookAuth.instance.login();
                          //   if (result.status == LoginStatus.success) {
                          //     final AccessToken accessToken = result.accessToken!;
                          //     final AuthCredential credential =
                          //     FacebookAuthProvider.credential(accessToken.token);
                          //     await FirebaseAuth.instance.signInWithCredential(credential);
                          //     // Sign-in with Facebook successful, perform any additional actions
                          //     // or navigate to another screen.
                          //     print('Signed in with Facebook successfully!');
                          //   } else if (result.status == LoginStatus.cancelled) {
                          //     // User cancelled the Facebook sign-in.
                          //     print('Facebook sign-in cancelled by user.');
                          //   } else {
                          //     // Error occurred during Facebook sign-in.
                          //     print('Error signing in with Facebook: ${result.message}');
                          //   }
                          // } catch (error) {
                          //   // Handle any errors during the sign-in process.
                          //   print('Error signing in with Facebook: $error');
                          // }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * .8,
                          height: 50,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              color: Colors.blue
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
                                    color: Colors.white
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
                        //     // Sign-in with Google successful, perform any additional actions
                        //     // or navigate to another screen.
                        //     print('Signed in with Google successfully!');
                        //   } else {
                        //     // User cancelled the Google sign-in.
                        //     print('Google sign-in cancelled by user.');
                        //   }
                        // } catch (error) {
                        //   // Handle any errors during the sign-in process.
                        //   print('Error signing in with Google: $error');
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
                                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
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
            ),
            const Center(
              // child: FutureBuilder<String>(
              //   future: getAppVersion(),
              //   builder: (BuildContext context, AsyncSnapshot<String> snapshot){
              //     if(snapshot.connectionState == ConnectionState.waiting){
              //       return const Text('Loading...');
              //     }else if(snapshot.hasError){
              //       return const Text("App version 1.0.0");
              //     }else{
              //       return Text('App version ${snapshot.data}');
              //     }
              //   },
              // ),
              child: Text("Version 1.0.0",
                style: TextStyle(
                  color: Color(0xFFA7A7A7)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
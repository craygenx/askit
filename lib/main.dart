import 'package:askit/Homepage.dart';
import 'package:askit/InitialScreen.dart';
import 'package:askit/NotificationManager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _onMessageBackground(RemoteMessage message)async {
  print('${message.messageId}');
}

class AuthService {
  final String loggedInKey = 'loggedInKey';

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(loggedInKey) ?? false;
    return isLoggedIn;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51Np7gQApX4mRdM7q4yQQr1AfuVotDKQKH9tl7XxYtru4YdAi2WjXa71blJ11WYJ1UAuzhIxIEwUIa4hzFMlPTRzx00dnNRfBAQ';
  await Stripe.instance.applySettings();
  NotificationManager().initNotification();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  AuthService authService = AuthService();
  bool isLoggedIn = await authService.isUserLoggedIn();
  await FirebaseMessaging.instance.getInitialMessage();
  PresenceManager().initPresence();
  FirebaseMessaging.onBackgroundMessage((message) => _onMessageBackground(message));
  runApp(MyApp(isLoggedIn: isLoggedIn));
}
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Askit',
      theme: ThemeData(
        fontFamily: 'montserrat',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const Homepage() : const InitialPage(),
    );
  }
}
class PresenceManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _presenceRef = FirebaseDatabase.instance.ref().child('user_presence');

  void updateUserPresence(String status) async {
    if (_auth.currentUser != null) {
      String uid = _auth.currentUser!.uid;
      await _presenceRef.child(uid).update(<String, dynamic>{
        'status': status,
      });
    }
  }

  void initPresence() {
    WidgetsBinding.instance.addObserver(AppLifecycleListener(this));
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
  }
}

class AppLifecycleListener extends WidgetsBindingObserver {
  final PresenceManager _presenceManager;

  AppLifecycleListener(this._presenceManager);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    String status = state == AppLifecycleState.resumed ? 'online' : 'offline';
    _presenceManager.updateUserPresence(status);
  }
}

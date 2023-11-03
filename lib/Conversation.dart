import 'dart:convert';
import 'dart:io';

import 'package:askit/CustomWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:askit/DataModel.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Conversations extends StatefulWidget {
  final String receiverId;
  final String profileName;
  const Conversations({Key? key, required this.receiverId, required this.profileName}) : super(key: key);

  @override
  State<Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<Conversations> {
  Map<String, dynamic> userData = {};
  final FlutterLocalNotificationsPlugin  notificationsPlugin = FlutterLocalNotificationsPlugin();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool status = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, (){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _scrollController.jumpTo(_scrollController.posit
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(microseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    });
    requestPermission();
    initInfo();

    // if (auth.currentUser != null){
    //   String uid = auth.currentUser!.uid;
    //   DatabaseReference userRef = FirebaseDatabase.instance.ref().child('user_presence').child(uid);
    //   userRef.onValue.listen((DatabaseEvent event) {
    //     if(event.snapshot.exists){
    //       userData = event.snapshot.value as Map<String, dynamic>;
    //
    //     }
    //     // final precence = event.snapshot.value ;
    //     // userData = precence as Map<String, dynamic>;
    //     // setState(() {
    //     //   status = precence;
    //     // });
    //   });
    // }
  }
  @override
  dispose(){
    _scrollController.dispose();
    super.dispose();
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
  Future<Map<String, dynamic>> getServiceAccCredentials() async{
    const relativePath = 'app/sdkAdmin.json';
    final appDir = await getApplicationDocumentsDirectory();
    final fullPath = path.join(appDir.path, relativePath);
    print(fullPath);
    final file = File(fullPath);
    final jsonString = await file.readAsString();
    return json.decode(jsonString);
  }

  Future<String> getBearerToken() async{
    final serviceAcc = await getServiceAccCredentials();
    print(serviceAcc);
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': '''MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDNI1IbGahZiVLj
    5jRjY4PWFMb6tnus+cgtZnjeEEbdpX4lrJQtdvG/tRLmzZ+5aNDC/zqY4ueWXbPT
    4P8NqmrO6sHQovNk99KNBZ0C02+W02d8AuKDnvOkglofkA8nFEHdHu0KOjs+68EO
    H4ddzzknB8Psp3YvOQNYFULhOSJVp515iHU+YOynxJGRZt3/9NlKq4WWCpvwbzld
    GAxCCJ7/hMnsukwaQudntk32Hs6CX7U5CXZmsMIEG0owJlFvqy//7Sy/5RrBBaQ1
    dooYu3Nur22+cHrTVYgpUBv23W5NiXMr3EXgbbsU0ceMlAwybh+8u+OXbE9mcdez
    SsXmauFZAgMBAAECggEAA3BTaob+hoaavJ1kdqa5lDXcnu/bLh0xJVvoyK0UZbQ7
    VUoCmhvXKw6W9OoUScIb/x1EhV2xt5iD99EiBWp1MueNizHA/VEIM3sZODTaKPi2
    XsZRYhbn4JApR9IO5vf4ducTUIC+LBAgqfhVcfkwXszZPx4tF0jI/tfz9B0iy+5s
    SP3m6jD6ciAD2nk4p4VvpOchu8iY4rN4OR529nH5P+cnXaEbaDXMzrhzepmu/4hp
    vCxP3qx4jwAJrVN3C2mQs+H3bhS8gLBNcOlod1rftw0PclnpssfNsGAXqYFA8FKq
    vD45nv51Xcmk1KZlkdofnSuxNaDJhJ1LcozSGq+HtwKBgQD3x+hJpUUmr7K7g2C7
    DVSxghzzEPRfjvZKpIoMhfTzTWiG8KH6vmF7WmdG++YI7Iqk760NH4OxRj0XF5bR
    LEC9OiReWSlld3O/W1AM+GYQDzlluht/CCLSIky3ejR4Ke+cxp1KJRfqjbSNzuBY
    2Vc1QQcCLe/QHzip96n8wmJp7wKBgQDT8Uzs+/KMYCy3YFPvlnHMIIKQ204vs8NC
    FUeETln8He5luscTUHCspVwU7wz3eqd4rE51c0RkHkpe8tsLB8M6heJXAWu14y0s
    K+lMGsc937oc6zlpJvt0BxcPqEshtY0jHo8isuo64jKBqcpUg9e/yOHAi85U05Wz
    G/Ijk9bRNwKBgCdQ+iPNbKaR1Ht6gjvMBrdP3QYYl54eEiiP6TPJga+lhcN7pUgj
    M1aeZqrVx4988RbwzPW7HWtgqMrkPFMegXtFIYYzAaWPCbfAZnhYZeGAeOwSVtCW
    Wuga9y9Z3b9/b/zhaw3byuq154Nk4yZV/kd99P28ikPs4FHf8YIg2frTAoGAaRzY
    kQQXdAVSyBOPLVkI0TsiZiNN8JyP71tMX9LYEBDsJinvB6Yya32LYJp6bNa47kFO
    nDNxrNHVAqgheKP98C1sZsg+mjO0OJ8CkosJW6d0z1jd3UfHF/FYP5ywvmQjPlKu
    nH/taQy8DdCelzHYM7a2N99eknVpXi4y9fAhbxsCgYBeIJfBN/OZgiMlu9XyP91K
    9WVCbiVos9fSXf1kyw7TVBYgKCKK7b5QR7DrVPDmy2JDwIhpxw8WZhul9HNFScgm
    ntKSFjvZz2CgwrJRH24FQtEzyb4BuczkH6SaK+9esxQUYZR+ceayDnH9Ebt03O+6
    fnw1E/0cLEu12mdVqsWVHA'''}
    );
    if(response.statusCode == 200){
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['access_token'];
    }else{
      print(response.statusCode);
      throw Exception('Failed to fetch access token');
    }
  }

  void requestPermission() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      return;
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      return;
    }else{
      return;
    }
  }
  Future<String> getUserToken(String uid) async{
    try{
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if(snapshot.exists){
        String userToken = snapshot['fcmToken'] as String;
        return userToken;
      }else{
        return '';
      }
    }catch(error){
      showToastMessage('$error', Colors.red);
    }
    return '';
  }
  initInfo(){
    var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings initializationIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload){},
    );
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: initializationIos);
    notificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async{
      try{
        if(notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty){
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
            return const Conversations(receiverId: '', profileName: '');
          }));
        }else{}
      }catch(e){
        return;
      }
    });
  }
  void sendPushMessage(String token, String body, String title) async{
    final accessToken = await getBearerToken();
    print(accessToken);
    // try{
    //   final http.Response response = await http.post(
    //     Uri.parse('https://fcm.googleapis.com/v1/projects/askit-5ff8c/messages:send HTTP/1.1'),
    //     headers:{
    //       'Authorization': 'Bearer 60693c26c90360664fbaade6b5ea2b003aa2c16f',
    //       'Content-Type': "application/json",
    //   },
    //     body: jsonEncode(
    //       <String, dynamic>{
    //         'priority': 'high',
    //         'data':<String, dynamic>{
    //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    //           'status': 'done',
    //           'body': body,
    //           'title':title,
    //         },
    //         "message":{
    //           "token":token,
    //           "notification":{
    //             'title':title,
    //             'body':body,
    //             "android_channel_id": "sentMessage"
    //           }
    //         },
    //       }
    //     )
    //   );
    //   if(response.statusCode == 200){
    //     print('succesful');
    //   }else{
    //     print('failede');
    //     print('body: ${response.body}');
    //   }
    // }catch(e){
    //   showToastMessage('$e', Colors.red);
    // }
  }
  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        message.notification!.body.toString(), htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(), htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          'sentMessage',
          'sentMessage',
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.max,
        playSound: false,
      );
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );
      await notificationsPlugin.show(0, message.notification?.title, message.notification?.body, notificationDetails, payload: message.data['body']);
    });
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(
                //   width: MediaQuery.of(context).size.width,
                //   child: StreamBuilder<DocumentSnapshot>(
                //     stream: firestore.collection('users').doc(widget.receiverId).snapshots(),
                //     builder: (context, snapshot){
                //       if(snapshot.hasError){
                //         return const Text('error');
                //       }
                //       if(snapshot.connectionState == ConnectionState.waiting){
                //         return const CircularProgressIndicator();
                //       }
                //       // final String documents = snapshot.data?[''];
                //       return SizedBox(
                //         child: Row(
                //           children: [
                //             SizedBox(
                //               child: Row(
                //                 children: [
                //                   const CircleAvatar(),
                //                   Padding(
                //                     padding: const EdgeInsets.only(left: 8.0),
                //                     child: SizedBox(
                //                       child: Column(
                //                         crossAxisAlignment: CrossAxisAlignment.start,
                //                         children: [
                //                           CustomText(text: widget.profileName, fontSize: 16,),
                //                           CustomText(text: snapshot.data?['online'] ? '. Online': '. Offline',  color: snapshot.data?['online'] ? Colors.green : Colors.grey,)
                //                         ],
                //                       ),
                //                     ),
                //                   )
                //                 ],
                //               ),
                //             )
                //           ],
                //         ),
                //       );
                //     },
                //   ),
                // ),
                SizedBox(
                  child: Row(
                    children: [
                      SizedBox(
                        child: Row(
                          children: [
                            const CircleAvatar(),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(text: widget.profileName, fontSize: 16,),
                                    CustomText(text: status ? '. Online' : '. offline', color: status ? Colors.green : Colors.grey,)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SizedBox(
                    child: GestureDetector(
                      onTap: (){},
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const CustomText(text: 'Make An Offer'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection('users').doc(auth.currentUser!.uid.toString()).collection('chats').doc(widget.receiverId).collection('messages').orderBy('timeSent', descending: false).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if(snapshot.hasError){
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        final List<DocumentSnapshot> documents = snapshot.data!.docs;
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: documents.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                                return Align(
                                  alignment: data['senderId'] == auth.currentUser!.uid ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20.0 ,right: 20.0, bottom: 10),
                                      child: Container(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .7),
                                        decoration: BoxDecoration(
                                          color: Colors.white30,
                                          borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(data['textMessage'],
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                );
                            },
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child : Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * .85,
                              child: TextField(
                                controller: _textController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none
                                ),
                                style: const TextStyle(
                                  color: Colors.white
                                ),
                              ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async{
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(microseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            });
                            //String userToken = await getUserToken(widget.receiverId);
                            ChatRepo(firestore: FirebaseFirestore.instance, auth: FirebaseAuth.instance)
                            .sendTextMessage(context: context, textMessage: _textController.text, receiverId: widget.receiverId);
                            // sendPushMessage('', '${widget.profileName} ${_textController.text}', 'Askit');
                            _textController.clear();
                          },
                            child: const SizedBox(
                              child: CustomText(text: 'Send', color: Colors.blue, fontSize: 12,),
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        'Messages',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}

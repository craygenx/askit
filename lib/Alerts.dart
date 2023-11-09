import 'dart:convert';

import 'package:askit/CustomWidgets.dart';
import 'package:askit/TaskBrief.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:askit/Conversation.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Alerts extends StatefulWidget {
  const Alerts({Key? key}) : super(key: key);

  @override
  State<Alerts> createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late dynamic paymentIntent;
  // final Timestamp firestoreTimestamp = Timestamp.fromDate(DateTime.now());
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // List<String> notifications = [];

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

  String formatDate(Timestamp timeStamp) {
    final now = Timestamp.now();
    final difference = now.seconds - timeStamp.seconds;
    if (difference >= 86400) {
      return '${difference ~/ 86400} days ago';
    } else if (difference >= 3600) {
      return '${difference ~/ 3600} h';
    } else if (difference >= 60) {
      return '${difference ~/ 60} m';
    } else {
      return 'Just now';
    }
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('100', 'usd');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.light,
                  merchantDisplayName: 'dennis'))
          .then((value) {});
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          headers: {
            'Authorization':
                'Bearer sk_test_51Np7gQApX4mRdM7q4bKihv7mlRZd23NZ5MYqUmk82C9EBrePCuwlCCMfHbZysIjY3hFXSoOzWQgtJpHARxsaL1EU00ATEnBx5C',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: body);
      return jsonDecode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  String calculateAmount(String amount) {
    return (int.parse(amount) * 100).toString();
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      showToastMessage('error: $e', Colors.white);
    } catch (e) {
      showToastMessage('$e', Colors.white);
    }
  }
  Future<String> getUsername(uid) async{
    try{
      DocumentSnapshot snap = await firestore.collection('users').doc(uid).get();
      if (snap.exists){
        Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
        return '${data['firstName']} ${data['lastName']}';
      }
    }catch(e){
      return 'no user';
    }
    return '';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('Alerts')
                      .where('uploadId', isNotEqualTo: _auth.currentUser!.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    return ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          String receiverNames = '';
                          final Map<String, dynamic> data =
                              documents[index].data() as Map<String, dynamic>;
                          if (data['msgReceiver'] != '' && data['msgReceiver'] != 'no user'){
                            receiverNames = getUsername(data['msgReceiver']) as String;
                          }
                          if (data['alertType'] == 'message' &&
                              data['msgReceiver'] == _auth.currentUser!.uid) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Conversations(
                                                receiverId: data['msgSender'],
                                                profileName: receiverNames,
                                              )));
                                },
                                child: Container(
                                  height: 80,
                                  color: Colors.white10,
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircleAvatar(),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 300,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                  text: receiverNames,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                CustomText(
                                                    text: formatDate(
                                                        data['timeStamp'])),
                                              ],
                                            ),
                                          ),
                                          CustomText(
                                            text: data['msgBody'],
                                            color: Colors.white,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (data['alertType'] == 'Offer' &&
                              data['msgReceiver'] == _auth.currentUser!.uid) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Container(
                                decoration:
                                    const BoxDecoration(color: Colors.white10),
                                height: 100,
                                width: MediaQuery.of(context).size.width * 0.95,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.95,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const CustomText(
                                                text: 'Task description'),
                                            CustomText(
                                                text: formatDate(
                                                    data['timeStamp'])),
                                          ],
                                        )),
                                    // const SizedBox(child: CustomText(text: 'Offer: 300')),
                                    Text(
                                      'Offer: ${data['taskBudget']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.95,
                                      height: 35,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            child: Row(
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      final DocumentReference
                                                          documentReference =
                                                          firestore
                                                              .collection(
                                                                  'Tasks')
                                                              .doc(data[
                                                                  'taskId']);
                                                      documentReference.update({
                                                        'status': 'closed'
                                                      }).onError(
                                                          (error, stackTrace) {
                                                        showToastMessage(
                                                            'Error occurred',
                                                            Colors.white);
                                                      });
                                                      makePayment();
                                                      showToastMessage(
                                                          'Offer accepted',
                                                          Colors.white);
                                                    },
                                                    child: const Text('Accept'))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else if (data['alertType'] == 'task') {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TaskBrief(
                                                data: data,
                                                taskId: data['taskId'],
                                              )));
                                },
                                child: Container(
                                  height: 120,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    color: Colors.white10,
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: SizedBox(
                                          width: 45,
                                          height: 35,
                                          child: Image.asset(
                                            data['taskUrl'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 300,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    child: CustomText(
                                                  text: data['taskTitle'],
                                                  fontSize: 16,
                                                )),
                                                SizedBox(
                                                    child: CustomText(
                                                  text: formatDate(
                                                      data['timeStamp']),
                                                  fontSize: 14,
                                                ))
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 240,
                                            child: Text(
                                              data['taskDescription'],
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                          CustomText(
                                            text: data['taskDueDate'],
                                            color: Colors.grey,
                                          ),
                                          const CustomText(
                                            text: 'Budget: 600',
                                            fontSize: 16,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const Visibility(
                                visible: false, child: Text(''));
                          }
                          // }else{
                          //   return Padding(
                          //     padding: const EdgeInsets.only(top: 10, bottom: 10),
                          //     child: Container(
                          //       decoration: const BoxDecoration(
                          //           color: Colors.white10
                          //       ),
                          //       height: 100,
                          //       width: MediaQuery.of(context).size.width * 0.95,
                          //       child: Column(
                          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           SizedBox(
                          //               width: MediaQuery.of(context).size.width * 0.95,
                          //               child: Row(
                          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   CustomText(text: '${data['taskTitle']}'),
                          //                   CustomText(text: formatDate(data['timeStamp'])),
                          //                 ],
                          //               )),
                          //           // const SizedBox(child: CustomText(text: 'Offer: 300')),
                          //           Text('Offer: ${data['taskBudget']}',
                          //             style: const TextStyle(
                          //               color: Colors.white,
                          //             ),
                          //           ),
                          //           SizedBox(
                          //             width: MediaQuery.of(context).size.width * 0.95,
                          //             height: 35,
                          //             child: Row(
                          //               mainAxisAlignment: MainAxisAlignment.end,
                          //               children: [
                          //                 SizedBox(
                          //                   child: Row(
                          //                     children: [
                          //                       ElevatedButton(
                          //                           onPressed: (){
                          //                             print(data['taskId']);
                          //                             final DocumentReference documentReference = firestore.collection('Tasks').doc(data['taskId']);
                          //                             documentReference.update({'status': 'closed'})
                          //                                 .onError((error, stackTrace){
                          //                               showToastMessage('Error occurred', Colors.white);
                          //                             });
                          //                             makePayment();
                          //                             showToastMessage('Offer accepted', Colors.white);
                          //                           },
                          //                           child: const Text('Accept'))
                          //                     ],
                          //                   ),
                          //                 )
                          //               ],
                          //             ),
                          //           )
                          //         ],
                          //       ),
                          //     ),
                          //   );
                          // }
                        });
                  }),
            ),
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
        'Alerts',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}

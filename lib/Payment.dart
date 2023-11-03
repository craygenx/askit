import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class BankCardWidget extends StatefulWidget {
  const BankCardWidget({super.key});

  @override
  State<BankCardWidget> createState() => _BankCardWidgetState();
}

class _BankCardWidgetState extends State<BankCardWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late dynamic paymentIntent;

  void showToastMessage(String message, Color textColor)=> Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.TOP,
    toastLength: Toast.LENGTH_LONG,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.grey,
    textColor: textColor,
    fontSize: 16,
  );

  Future<void> makePayment() async{
    try{
      paymentIntent = await createPaymentIntent('100', 'usd');
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'],
            style: ThemeMode.light,
            merchantDisplayName: 'dennis'
          )
      ).then((value) {});
      displayPaymentSheet();
    }catch(err){
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
            'Authorization': 'Bearer sk_test_51Np7gQApX4mRdM7q4bKihv7mlRZd23NZ5MYqUmk82C9EBrePCuwlCCMfHbZysIjY3hFXSoOzWQgtJpHARxsaL1EU00ATEnBx5C',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: body
      );
      return jsonDecode(response.body);
    }catch(err){
      throw Exception(err.toString());
    }
  }
  String calculateAmount(String amount) {
    return (int.parse(amount) * 100).toString();
  }

  displayPaymentSheet() async{
    try{
      await Stripe.instance.presentPaymentSheet().then((value){
        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    }
    on StripeException catch(e){
      showToastMessage('error: $e', Colors.white);
    }
    catch (e){
      showToastMessage('$e', Colors.white);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    makePayment();
  }

  @override
  Widget build(BuildContext context) {
    return  const Scaffold(
      backgroundColor: Colors.black,
    );
    // return Container(
    //   width: 300,
    //   height: 200,
    //   decoration: BoxDecoration(
    //     color: Colors.blue,
    //     borderRadius: BorderRadius.circular(12.0),
    //   ),
    //   child: const Column(
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Padding(
    //         padding: EdgeInsets.all(12.0),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               'Bank Name',
    //               style: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 20,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //             Icon(
    //               Icons.credit_card,
    //               color: Colors.white,
    //             ),
    //           ],
    //         ),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.all(12.0),
    //         child: Text(
    //           '**** **** **** 1234',
    //           style: TextStyle(
    //             color: Colors.white,
    //             fontSize: 24,
    //             letterSpacing: 4,
    //           ),
    //         ),
    //       ),
    //       Padding(
    //         padding: EdgeInsets.all(12.0),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Text(
    //               'VALID\nTHRU',
    //               style: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 12,
    //               ),
    //             ),
    //             Text(
    //               '12/25',
    //               style: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 20,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
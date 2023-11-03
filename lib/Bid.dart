import 'package:askit/DataModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:askit/CustomWidgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class Bid extends StatefulWidget {
  final String taskId;
  final String postOwner;
  final String taskTitle;
  final List<String> offers;
  const Bid({Key? key, required this.taskId, required this.postOwner, required this.taskTitle, required this.offers}) : super(key: key);

  @override
  State<Bid> createState() => _BidState();
}

class _BidState extends State<Bid> {
  var uuid = const Uuid();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _offerPrice = TextEditingController();
  final TextEditingController _info = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _offerPrice.dispose();
    _info.dispose();
  }

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: CustomTextField(
                width: MediaQuery.of(context).size.width * .95,
                maxLines: 2,
                controller: _offerPrice,
                hintText:
                'Add your price offer'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: CustomTextField(
                width: MediaQuery.of(context).size.width * .95,
                maxLines: 4,
                controller: _info,
                hintText:
                'Add more detailed description about the offer'),
          ),
          ElevatedButton(
              onPressed: () async{
                  if(widget.offers.contains(auth.currentUser!.uid)) {
                    OfferModel offerModel = OfferModel(offerInfo: _info.text,
                        offerPrice: _offerPrice.text,
                        status: 'received');
                    AlertModel alertModel = AlertModel(alertType: 'Offer',
                        username: '',
                        taskTitle: widget.taskTitle,
                        address: '',
                        taskBudget: _offerPrice.text,
                        timeStamp: DateTime.now(),
                        taskId: widget.taskId,
                        msgSender: '',
                        msgBody: '',
                        msgReceiver: widget.postOwner,
                        taskDescription: _info.text,
                        taskDueDate: '',
                        uploadId: '',
                        taskUrl: '');
                    Map<String, dynamic> dataMap = offerModel.toMap();
                    Map<String, dynamic> alertMap = alertModel.toMap();
                    var taskUuid = uuid.v1();
                    await FirebaseFirestore.instance
                        .collection("Offers").doc(taskUuid).set(dataMap);
                    await FirebaseFirestore.instance
                        .collection("Alerts").doc(taskUuid).set(alertMap);
                    final DocumentReference documentReference = firestore
                        .collection('Tasks').doc(widget.taskId);
                    documentReference.update({
                      'offers': FieldValue.arrayUnion([auth.currentUser!.uid])
                    })
                        .onError((error, stackTrace) {
                      showToastMessage('Error occurred', Colors.white);
                    });
                    _info.clear();
                    _offerPrice.clear();
                  } else {
                    showToastMessage('Offer already submitted', Colors.white);
                  }
              },
              child: const Text('Send offer'))
        ]
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
        'Make an offer',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}

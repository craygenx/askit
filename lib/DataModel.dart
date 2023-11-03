import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import 'MessageModel.dart';

class TaskModel {
  String? user_id;
  String username;
  String status;
  String Task_id;
  String title;
  String task_type;
  String country;
  String lat_coordinate;
  String lng_coordinate;
  String provider_id;
  int star_rate;
  bool complete;
  DateTime on_date_formatted;
  String png_icon;
  String description;
  String requirements;
  String category;
  List media_url;
  List offers;
  String vidPath;
  String city;
  String address;
  String on_date;
  String before_date;
  bool flexible_time;
  String preferred_time;
  bool flexible_date;

  TaskModel(
      {required this.user_id,
        required this.username,
        required this.status,
        required this.Task_id,
        required this.country,
        required this.lng_coordinate,
        required this.lat_coordinate,
        required this.provider_id,
        required this.on_date_formatted,
        required this.png_icon,
        required this.task_type,
        required this.complete,
        required this.star_rate,
      required this.title,
      required this.description,
      required this.requirements,
      required this.category,
      required this.media_url,
      required this.offers,
      required this.vidPath,
      required this.city,
      required this.address,
      required this.on_date,
      required this.before_date,
      required this.flexible_time,
      required this.preferred_time,
      required this.flexible_date});

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return TaskModel(
        user_id: data!['user_id'],
        username: data['username'],
        status: data['status'],
        Task_id: data['Task_id'],
        title: data['title'],
        description: data['description'],
        requirements: data['requirements'],
        category: data['category'],
        media_url: data['media_url'],
        offers: data['offers'],
        vidPath: data['vidPath'],
        city: data['city'],
        address: data['address'],
        on_date: data['on_date'],
        before_date: data['before_date'],
        flexible_time: data['flexible_time'],
        preferred_time: data['preferred_time'],
        flexible_date: data['timeFlexibility'],
        country: data['country'],
        lng_coordinate: data['lng_coordinate'],
        lat_coordinate: data['lat_coordinate'],
        provider_id: data['provider_id'],
        on_date_formatted: data['on_date_formatted'],
        png_icon: data['png_icon'],
        task_type: data['Icons.task'],
        complete: data['complete'],
        star_rate: data['star_rate'],

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': user_id,
      'username': username,
      'status': status,
      'Task_id': Task_id,
      'title': title,
      'description': description,
      'requirements': requirements,
      'category': category,
      'media_url': media_url,
      'offers': offers,
      'videoPath': vidPath,
      'city': city,
      'address': address,
      'onDate': on_date,
      'beforeDate': before_date,
      'flexible_time': flexible_time,
      'preferredTime': preferred_time,
      'timeFlexibility': flexible_date,
      'country': country,
      'lng_coordinate': lng_coordinate,
      'lat_coordinate': lat_coordinate,
      'provider_id': provider_id,
      'on_date_formatted': on_date_formatted,
      'png_icon': png_icon,
      'task_type': task_type,
      'complete': complete,
      'star_rate': star_rate,
    };
  }
}

class ChatRepo{
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  var uuid = const Uuid();
  late String username;

  ChatRepo({required this.firestore, required this.auth});

  Future<String> getUsername() async{
    try{
      DocumentSnapshot snap = await firestore.collection('users').doc(auth.currentUser!.uid).get();
      if (snap.exists){
        Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
          return '${data['firstName']} ${data['lastName']}';
      }
    }catch(e){
      return 'no user';
    }
    return '';
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

  void sendTextMessage({
    required BuildContext context,
    required String textMessage,
    required String receiverId,
  })async{
    try {
      String textMessageId = uuid.v1();
      final timeSent = DateTime.now();
      final receiverData = await firestore.collection('users').doc(receiverId).get();
      saveToMessageCollection(receiverId: receiverId, textMessage: textMessage,
          timeSent: timeSent, textMessageId: textMessageId,
          senderUsername: auth.currentUser!.displayName, receiverUsername: receiverData['firstName']);
      saveAsLastMessage(lastMessage: textMessage, receiverId: receiverId, timeSent: timeSent, messageId: textMessageId);
      AlertModel alertModel = AlertModel(alertType: 'message', taskTitle: '', address: '',
          taskBudget: '', timeStamp: timeSent, taskId: '', msgSender: auth.currentUser!.uid,
          msgBody: textMessage, msgReceiver: receiverId, taskDescription: '', taskDueDate: '', uploadId: auth.currentUser!.uid, taskUrl: '', username: await getUsername());
      Map<String, dynamic> alertData = alertModel.toMap();
      await FirebaseFirestore.instance.collection('Alerts').add(alertData);
    } catch(e) {
      showToastMessage(e.toString(), Colors.deepOrange);
    }
  }

  void saveToMessageCollection({
    required String receiverId,
    required String textMessage,
    required DateTime timeSent,
    required String textMessageId,
    required String? senderUsername,
    required String receiverUsername,
  })async{

    final message = MessageModel(senderId: auth.currentUser!.uid, receiverId: receiverId,
        textMessage: textMessage, timeSent: timeSent, messageId: textMessageId);
    await firestore.collection('users').doc(auth.currentUser!.uid).collection('chats')
    .doc(receiverId).collection('messages').doc(textMessageId).set(message.toMap());
    await firestore.collection('users').doc(receiverId).collection('chats')
        .doc(auth.currentUser!.uid).collection('messages').doc(textMessageId).set(message.toMap());
  }

  void saveAsLastMessage({
    required String lastMessage,
    required String receiverId,
    required DateTime timeSent,
    required String messageId,
  })async{
    Map<String, dynamic> currentData;
    Map<String, dynamic> receiverData;
    DocumentSnapshot receiver = await firestore.collection('users').doc(receiverId).get();
    DocumentSnapshot current = await firestore.collection('users').doc(auth.currentUser!.uid).get();
    currentData = current.data() as Map<String, dynamic>;
    receiverData = receiver.data() as Map<String, dynamic>;
    final receiverLastMessage = LastMessage(senderId: auth.currentUser!.uid, receiverId: receiverId,
        textMessage: lastMessage, timeSent: DateTime.now(), messageId: messageId, receiverNames: '${currentData['firstName']} ${currentData['lastName']}',
    );
    await firestore.collection('users').doc(receiverId).collection('chats').
    doc(auth.currentUser!.uid).set(receiverLastMessage.toMap());

    final senderLastMessage = LastMessage(senderId: auth.currentUser!.uid, receiverId: receiverId,
      textMessage: lastMessage, timeSent: DateTime.now(), messageId: messageId, receiverNames: '${receiverData['firstName']} ${receiverData['lastName']}',
    );
    await firestore.collection('users').doc(auth.currentUser!.uid).collection('chats').
    doc(receiverId).set(senderLastMessage.toMap());
  }
}
class AlertModel{
  String alertType;
  String username;
  String taskTitle;
  String taskUrl;
  String address;
  String taskBudget;
  DateTime timeStamp;
  String taskId;
  String msgSender;
  String msgBody;
  String msgReceiver;
  String taskDescription;
  String taskDueDate;
  String uploadId;

  AlertModel({required this.alertType, required this.username, required this.taskTitle, required this.address, required this.taskBudget, required this.timeStamp,
    required this.taskId, required this.msgSender, required this.msgBody, required this.msgReceiver, required this.taskDescription,
    required this.taskDueDate, required this.uploadId, required this.taskUrl});

  factory AlertModel.fromFirestore(DocumentSnapshot doc){
    Map? data = doc.data() as Map?;
    return AlertModel(alertType: data!['alertType'], taskTitle: data['taskTitle'], address: data['address'],
        taskBudget: data['taskBudget'], timeStamp: data['timeStamp'], taskId: data['taskId'], msgSender: data['msgSender'],
        msgBody: data['msgBody'], msgReceiver: data['msgReceiver'], taskDescription: data['taskDescription'], taskDueDate: data['taskDueDate'],
        uploadId: data['uploadId'], taskUrl: data['taskUrl'], username: data['username']);
  }
  Map<String, dynamic> toMap(){
    return {
      'alertType' : alertType,
      'taskTitle': taskTitle,
      'address': address,
      'taskBudget': taskBudget,
      'timeStamp': timeStamp,
      'taskId': taskId,
      'msgSender': msgSender,
      'msgBody': msgBody,
      'msgReceiver': msgReceiver,
      'taskDescription': taskDescription,
      'taskDueDate': taskDueDate,
      'uploadId': uploadId,
      'taskUrl': taskUrl,
      'username': username,
    };
  }
}

class OfferModel{
  String offerPrice;
  String offerInfo;
  String status;
  OfferModel({
    required this.offerInfo,
    required this.offerPrice,
    required this.status,
  });
  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    Map? data = doc.data() as Map?;
    return OfferModel(
      offerInfo: data?['offerInfo'],
      offerPrice: data?['offerPrice'],
      status: data?['status']
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'offerPrice': offerPrice,
      'offerInfo': offerInfo,
    };
  }
}

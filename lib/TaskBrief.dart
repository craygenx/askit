import 'dart:async';

import 'package:askit/Bid.dart';
import 'package:askit/CustomWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Conversation.dart';
import 'ImagesPreview.dart';
import 'VidPlayer.dart';

class TaskBrief extends StatefulWidget {
  final Map<String, dynamic> data;
  final String taskId;
  const TaskBrief({Key? key, required this.data, required this.taskId}) : super(key: key);

  @override
  State<TaskBrief> createState() => _TaskBriefState();
}

class _TaskBriefState extends State<TaskBrief> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, dynamic> taskData = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.taskId.isNotEmpty){
      getTaskDocument(widget.taskId);
    }
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

  Future<void> getTaskDocument(String docId) async{
    try{
      DocumentSnapshot docSnapshot = await firestore.collection('Tasks').doc(docId).get();
      if(docSnapshot.exists){
        setState(() {
          taskData = docSnapshot.data() as Map<String, dynamic>;
        });
      }else{
        showToastMessage("Task not found", Colors.red);
      }
    }catch(e){
      showToastMessage('error: $e', Colors.red);
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
  void autoRedirectTimer(){
    Timer.periodic(const Duration(seconds: 3), (timer){
      auth.currentUser?.reload();
      final user = auth.currentUser;
      if(user!.emailVerified){
        timer.cancel();
        showToastMessage('Email verified', Colors.white);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // Future<Map<String, dynamic>> taskData = getTaskDocument(widget.taskId);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: SafeArea(
          child: widget.data.isNotEmpty ? Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.data['category'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          // CustomText(text: widget.data['category']),
                          SizedBox(
                            child: Text(widget.data['description'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            // child: CustomText(text: widget.data['description']),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                      child: CustomText(text: 'Open'),
                    )
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * .95,
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: CustomText(text: 'POSTED BY', fontSize: 12,),
                          ),
                          SizedBox(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(text: 'Ava Adams'),
                                      CustomText(text: '2 days ago'),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(text: 'BUDGET'),
                          CustomText(text: '300'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * .95,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(text: 'DUE DATE'),
                          CustomText(text: '24 July'),
                          CustomText(text: 'Evening (4pm-9pm)'),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(text: 'LOCATION'),
                          CustomText(text: 'Paldi,Ahmedabad'),
                          CustomText(text: 'View On Maps', color: Colors.blue),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('DESCRIPTION',
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                    Text(widget.data['description'],
                      style: const TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ImagePreview(images: widget.data['media_url'],)));
                      },
                      child: Container(
                        color: Colors.white12,
                        height: 200,
                        width: 170,
                        child: Center(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.data['media_url'].length,
                              itemBuilder: (BuildContext context,int index ){
                                return CircleAvatar(
                                  backgroundColor: Colors.red,
                                  backgroundImage: NetworkImage(widget.data['media_url'][index]),
                                );
                              }),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> VidPlayer(vidUrl: widget.data['videoPath'],)));
                      },
                      child: Container(
                        color: Colors.white12,
                        height: 200,
                        width: 170,
                        child: Text(widget.data['videoPath'],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Conversations(receiverId: widget.data['user_id'], profileName: 'John Doe',)));
                        },
                        child: Container(
                          width: 150,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const CustomText(text: 'Send message', color: Colors.black, fontSize: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async{
                          // await sendEmailVerification();
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Bid(taskId: widget.data['Task_id'], postOwner: widget.data['user_id'], taskTitle: widget.data['title'], offers: widget.data['offers'],)));
                        },
                        child: Container(
                          width: 150,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const CustomText(text: 'Make an offer', fontSize: 16,),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ) : Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(taskData['category'] ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          // CustomText(text: widget.data['category']),
                          SizedBox(
                            child: Text(taskData['description'] ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            // child: CustomText(text: widget.data['description']),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      child: CustomText(text: 'Open'),
                    )
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * .95,
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: CustomText(text: 'POSTED BY', fontSize: 12,),
                          ),
                          SizedBox(
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                                SizedBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(text: 'Ava Adams'),
                                      CustomText(text: '2 days ago'),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(text: 'BUDGET'),
                          CustomText(text: '300'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * .95,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(text: 'DUE DATE'),
                          CustomText(text: '24 July'),
                          CustomText(text: 'Evening (4pm-9pm)'),
                        ],
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(text: 'LOCATION'),
                          CustomText(text: 'Paldi,Ahmedabad'),
                          CustomText(text: 'View On Maps', color: Colors.blue),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('DESCRIPTION',
                      style: TextStyle(
                          color: Colors.white
                      ),
                    ),
                    Text(taskData['description'] ?? '',
                      style: const TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ImagePreview(images: taskData['media_url'],)));
                      },
                      child: Container(
                        color: Colors.white12,
                        height: 200,
                        width: 170,
                        child: Center(
                          child: taskData.isNotEmpty ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: taskData['media_url'].length,
                              itemBuilder: (BuildContext context,int index ){
                                return CircleAvatar(
                                  backgroundColor: Colors.red,
                                  backgroundImage: NetworkImage(taskData['media_url'][index]),
                                );
                              }) : const CustomText(text: 'No images'),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> VidPlayer(vidUrl: taskData['videoPath'],)));
                      },
                      child: Container(
                        color: Colors.white12,
                        height: 200,
                        width: 170,
                        child: taskData.isNotEmpty ? Text(taskData['videoPath'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                            )
                        ) : const Center(child: CustomText(text: 'No video')),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .85,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> Conversations(receiverId: taskData['user_id'], profileName: taskData['username'],)));
                        },
                        child: Container(
                          width: 150,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: const CustomText(text: 'Send message', color: Colors.black, fontSize: 16),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: (){
                      //     // print('hello');
                      //     // Navigator.push(context, MaterialPageRoute(builder: (context)=> Bid(taskId: taskData['Task_id'],)));
                      //   },
                      //   child: Container(
                      //     width: 150,
                      //     height: 40,
                      //     decoration: const BoxDecoration(
                      //       color: Colors.white12,
                      //       borderRadius: BorderRadius.all(Radius.circular(10)),
                      //     ),
                      //     child: const CustomText(text: 'Make an offer', fontSize: 16,),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              )
            ],
          )
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
        'Task brief',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}

import 'package:askit/Conversation.dart';
import 'package:askit/CustomWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String formatDate(Timestamp timeStamp){
    final now = Timestamp.now();
    final difference = now.seconds - timeStamp.seconds;
    if(difference >=86400){
      return '${difference ~/ 86400} days ago';
    }else if(difference >= 3600){
      return '${difference ~/ 3600} h';
    }else if(difference >= 60){
      return '${difference ~/ 60} m';
    }else{
      return 'Just now';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection('users').doc(auth.currentUser?.uid).collection('chats').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.connectionState == ConnectionState.waiting) {
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
                itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                    return GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Conversations(receiverId: data['receiverId'] == auth.currentUser!.uid? data['senderId'] : data['receiverId'], profileName: data['receiverNames'],)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Container(
                          height: 80,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white
                              )
                            )
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.cyan,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(text: data['receiverNames'], fontSize: 18.0,),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: CustomText(text: formatDate(data['timeSent'])),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(text: '${data['textMessage']}',),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
              );
            },
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


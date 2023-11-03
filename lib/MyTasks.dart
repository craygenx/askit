import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'CustomWidgets.dart';

class MyTasks extends StatefulWidget {
  const MyTasks({Key? key}) : super(key: key);

  @override
  State<MyTasks> createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {
  String _selectedFilter = 'All';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int availableTasks = 0;
  final List<String> categories = [
    'All',
    'Home Work & Assignments',
    'Office Work',
    'Lift-Move-Pack',
    'Tutoring',
    'Computer IT',
    'Cleaning',
    'Video & Editing',
    'Photography',
    'Design',
    'Delivery & Errands',
    'Pet Care',
    'Gardening & PlantCare',
    'Events',
    'Custom',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   leading: IconButton(
      //     onPressed: (){
      //       Navigator.pop(context);
      //     },
      //     icon: const Icon(Icons.arrow_back_ios_new,
      //       color: Colors.white,
      //     ),
      //   ),
      // ),
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 80,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: categories.length,
                                        itemBuilder: (BuildContext context, int index){
                                          final String categoryTitle = categories[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 15.0),
                                            child: GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  _selectedFilter = categoryTitle;
                                                });
                                              },
                                              child: Container(
                                                height: 10,
                                                constraints: const BoxConstraints(
                                                  minWidth: 70,
                                                ),
                                                decoration: BoxDecoration(
                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                    color: _selectedFilter == categoryTitle ? Colors.white : Colors.white30
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                  child: CustomText(text: categoryTitle, color: _selectedFilter == categoryTitle ? Colors.black : Colors.white,),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: SizedBox(
                                        child: Text("$availableTasks Tasks Found",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                    ),
                                  )
                                ]
                            )
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: SizedBox(
                            height: 300,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _selectedFilter != 'All' ? firestore.collection('Tasks').where('user_id', isEqualTo: _auth.currentUser!.uid)
                                  .where('category', isEqualTo: _selectedFilter).snapshots() : firestore.collection('Tasks').where('user_id', isEqualTo: _auth.currentUser!.uid)
                                  .snapshots(),
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
                                availableTasks = documents.length;
                                return ListView.builder(
                                  itemCount: documents.length,
                                  itemBuilder: (BuildContext context, int index){
                                    final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 15.0),
                                      child: TaskCard(data: data,),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

import 'dart:async';

import 'package:askit/CategoryPick.dart';
import 'package:askit/Messages.dart';
import 'package:askit/MyTasks.dart';
import 'package:askit/Profile.dart';
import 'package:askit/TaskBrief.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Alerts.dart';
import 'CustomWidgets.dart';
import 'Login.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchFieldController = TextEditingController();
  late User? user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedNav = "browse";
  int selectedTab = 0;
  int availableTasks = 0;
  bool searching = false;
  List<Map<String, dynamic>> filteredList = [];
  final List<Widget> _screens = [
    const Browse(),
    const MyTasks(),
    const CategoryPick(),
    const Alerts(),
    const Messages(),
  ];
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
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchFieldController.dispose();
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

  void handleFilter(value) async {
    List<Map<String, dynamic>> dataList = [];
    QuerySnapshot querySnapshot = await firestore
        .collection('Tasks')
        .where('user_id', isNotEqualTo: _auth.currentUser!.uid)
        .get();
    for (var doc in querySnapshot.docs) {
      dataList.add(doc.data() as Map<String, dynamic>);
    }

    setState(() {
      filteredList = dataList
          .where((element) =>
              element['description']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element['category']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element['address']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element['task_type']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      prefs.setBool('loggedInKey', false);
      await _auth.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const Login()));
    } catch (e) {
      showToastMessage('Error: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    String username = user?.displayName ?? "null";
    String email = user?.email ?? "null";
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFFA7A7A7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: SizedBox(
                        height: 150,
                        child: DrawerHeader(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                            child: Center(
                              child: SizedBox(
                                height: 150,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Profile(
                                                          title: '')));
                                        },
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.black,
                                          child: Image.asset(
                                            'assets/Group 2389.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hi, $username',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Text(
                                            email,
                                            style: const TextStyle(
                                                color: Color(0xFFA7A7A7)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => const BankCardWidget()));
                            },
                            child: ListTile(
                              leading: Image.asset('assets/Profile.png'),
                              title: const Text(
                                'My Account',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.white30,
                          ),
                          ListTile(
                            leading: Image.asset('assets/Wallet.png'),
                            title: const Text(
                              'Wallet Balance',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.white30,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=> const FlutterEmailVerification(email: '')));
                            },
                            child: ListTile(
                              leading: Image.asset('assets/v2.png'),
                              title: const Text(
                                'Payment History',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.white30,
                          ),
                          ListTile(
                            leading: Image.asset('assets/Star.png'),
                            title: const Text(
                              'Your Reviews',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.white30,
                          ),
                          ListTile(
                            leading: Image.asset('assets/v1.png'),
                            title: const Text(
                              'How it works',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.white30,
                          ),
                          ListTile(
                            leading: Image.asset('assets/Info Square.png'),
                            title: const Text(
                              'About Askit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.white30,
                          ),
                          ListTile(
                            leading: Image.asset('assets/Vector (2).png'),
                            title: const Text(
                              'Support',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Colors.white30,
                          ),
                          GestureDetector(
                            onTap: () {
                              _handleLogout();
                            },
                            child: ListTile(
                              leading: Image.asset('assets/Vector (3).png'),
                              title: const Text(
                                'Logout',
                                style: TextStyle(color: Color(0xFFF27B67)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'All rights reserved',
                      style: TextStyle(
                        color: Color(0xFFA7A7A7),
                      ),
                    ),
                    Text(
                      'Powered by Google',
                      style: TextStyle(
                        color: Color(0xFFA7A7A7),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNav = 'browse';
                  selectedTab = 0;
                });
              },
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _selectedNav == 'browse'
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: Image.asset(
                                'assets/highlightedNav/Discovery.png'))
                        : Image.asset('assets/Discovery.png'),
                    // Image.asset('assets/Discovery.png'),
                    Text(
                      'Browse',
                      style: TextStyle(
                        color: _selectedNav == 'browse'
                            ? Colors.white
                            : const Color(0xFFA7A7A7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNav = 'myTasks';
                  selectedTab = 1;
                  // Navigator.push(
                  //     context, MaterialPageRoute(builder: (context) => const MyTasks()));
                });
              },
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _selectedNav == 'myTasks'
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child:
                                Image.asset('assets/highlightedNav/Work.png'))
                        : Image.asset('assets/Work.png'),
                    // Image.asset('assets/Work.png'),
                    Text(
                      'My Tasks',
                      style: TextStyle(
                        color: _selectedNav == 'myTasks'
                            ? Colors.white
                            : const Color(0xFFA7A7A7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNav = 'postTask';
                  selectedTab = 2;
                });
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => const CategoryPick()));
              },
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _selectedNav == 'postTask'
                        ? SizedBox(
                            height: 25,
                            width: 25,
                            child: Image.asset(
                                'assets/highlightedNav/Group 2577.png'))
                        : Image.asset('assets/Plus.png'),
                    // Image.asset('assets/Plus.png'),
                    Text(
                      'Post Task',
                      style: TextStyle(
                        color: _selectedNav == 'postTask'
                            ? Colors.white
                            : const Color(0xFFA7A7A7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNav = 'alerts';
                  selectedTab = 3;
                });
              },
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _selectedNav == 'alerts'
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: Image.asset(
                                'assets/highlightedNav/Notification.png'))
                        : Image.asset('assets/Notification.png'),
                    // Image.asset('assets/Notification.png'),
                    Text(
                      'Alerts',
                      style: TextStyle(
                        color: _selectedNav == 'alerts'
                            ? Colors.white
                            : const Color(0xFFA7A7A7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNav = 'messages';
                  selectedTab = 4;
                });
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Messages()));
              },
              child: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _selectedNav == 'messages'
                        ? SizedBox(
                            height: 25,
                            width: 25,
                            child:
                                Image.asset('assets/highlightedNav/Chat.png'))
                        : Image.asset('assets/Chat.png'),
                    // Image.asset('assets/Chat.png'),
                    Text(
                      'Messages',
                      style: TextStyle(
                        color: _selectedNav == 'messages'
                            ? Colors.white
                            : const Color(0xFFA7A7A7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _screens[selectedTab],
    );
  }
}

class Browse extends StatefulWidget {
  const Browse({Key? key}) : super(key: key);

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchFieldController = TextEditingController();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<LatLng> markerPositions = [];
  final Set<Marker> _markers = {};
  LatLng location = const LatLng(19.0760, 72.8777);
  late User? user;
  String _selectedFilter = 'All';
  int availableTasks = 0;
  bool searching = false;
  List<Map<String, dynamic>> filteredList = [];
  final FocusNode _focusNode = FocusNode();
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
    'Socialising',
    'Custom',
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _getLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchFieldController.dispose();
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

  void handleFilter(value) async {
    List<Map<String, dynamic>> dataList = [];
    QuerySnapshot querySnapshot = await firestore
        .collection('Tasks')
        .where('user_id', isNotEqualTo: _auth.currentUser!.uid)
        .get();
    for (var doc in querySnapshot.docs) {
      dataList.add(doc.data() as Map<String, dynamic>);
    }

    setState(() {
      filteredList = dataList
          .where((element) =>
              element['description']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element['category']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element['address']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element['task_type']
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    });
  }

  void showAddressMap() {
    showGeneralDialog(
        context: context,
        pageBuilder: ((context, animation, secondaryAnimation) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: MaterialButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(CommunityMaterialIcons.chevron_left,
                    color: Colors.white, size: 20),
              ),
              centerTitle: true,
              title: const Text(
                'Map',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                    child: GoogleMap(
                  mapType: MapType.normal,
                  zoomGesturesEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(
                      target: location, zoom: 16, tilt: 80, bearing: 30),
                  onMapCreated: (GoogleMapController controller) =>
                      _controller.complete(controller),
                  markers: _markers,
                  // circles: _circles,
                ))
              ],
            ),
          );
        }));
    // } else{
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No address chosen')));
    // }
  }

  void _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        location = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      showToastMessage("Permission Denied", Colors.white);
    }
  }

  void _addMarkers() {
    // Map<String, dynamic> tskData = dataTask;
    for (var position in markerPositions) {
      double distance = Geolocator.distanceBetween(location.latitude,
          location.longitude, position.latitude, position.longitude);
      if (distance <= 10 * 1000) {
        _markers.add(Marker(
            markerId: MarkerId(position.toString()),
            position: position,
            infoWindow: const InfoWindow(
              title: 'Offer',
              snippet: 'Snippet',
            ),
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context)=> TaskBrief(data: dataTask, taskId: '')));
            }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Image.asset('assets/Vector.png'),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .75,
                    decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _searchFieldController,
                      focusNode: _focusNode,
                      onChanged: (value) => handleFilter(value),
                      onTap: () {
                        setState(() {
                          searching = true;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search tasks',
                        hintStyle: const TextStyle(color: Colors.white),
                        prefixIcon: IconButton(
                          onPressed: () {
                            _searchFieldController.clear();
                            _focusNode.unfocus();
                            filteredList.clear();
                            searching
                                ? setState(() {
                                    searching = false;
                                  })
                                : null;
                          },
                          icon: Icon(
                            searching ? Icons.close : Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.transparent,
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10.0, left: 10.0, right: 10.0),
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 80,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount: categories.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final String categoryTitle =
                                                  categories[index];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 15.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedFilter =
                                                          categoryTitle;
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 10,
                                                    constraints:
                                                        const BoxConstraints(
                                                      minWidth: 70,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    10)),
                                                        color: _selectedFilter ==
                                                                categoryTitle
                                                            ? Colors.white
                                                            : Colors.white10),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0,
                                                              right: 8.0),
                                                      child: CustomText(
                                                        text: categoryTitle,
                                                        color: _selectedFilter ==
                                                                categoryTitle
                                                            ? Colors.black
                                                            : Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: SizedBox(
                                            child: Text(
                                          "$availableTasks Tasks Found",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )),
                                      )
                                    ])),
                          ),
                          Expanded(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              child: SizedBox(
                                height: 300,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: _selectedFilter != 'All'
                                      ? firestore
                                          .collection('Tasks')
                                          .where('user_id',
                                              isNotEqualTo:
                                                  _auth.currentUser!.uid)
                                          .where('category',
                                              isEqualTo: _selectedFilter)
                                          .where('status', isEqualTo: 'open')
                                          .snapshots()
                                      : firestore
                                          .collection('Tasks')
                                          .where('user_id',
                                              isNotEqualTo:
                                                  _auth.currentUser!.uid)
                                          .where('status', isEqualTo: 'open')
                                          .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
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
                                    availableTasks = documents.length;
                                    return ListView.builder(
                                      itemCount: documents.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final Map<String, dynamic> data =
                                            documents[index].data()
                                                as Map<String, dynamic>;
                                        markerPositions.add(LatLng(
                                            double.parse(
                                                data['lat_coordinate']),
                                            double.parse(
                                                data['lng_coordinate'])));
                                        void addMarker(lat, long) {
                                          double distance =
                                              Geolocator.distanceBetween(
                                                  location.latitude,
                                                  location.longitude,
                                                  double.parse(lat),
                                                  double.parse(long));
                                          if (distance <= 10 * 1000) {
                                            _markers.add(Marker(
                                                markerId:
                                                    MarkerId(data['Task_id']),
                                                position: LatLng(
                                                    double.parse(lat),
                                                    double.parse(long)),
                                                infoWindow: const InfoWindow(
                                                  title: 'Offer',
                                                  snippet: '300',
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TaskBrief(
                                                                  data: data,
                                                                  taskId: '')));
                                                }));
                                          }
                                        }

                                        if (location != null) {
                                          addMarker(data['lat_coordinate'],
                                              data['lng_coordinate']);
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          TaskBrief(
                                                            data: data,
                                                            taskId: '',
                                                          )));
                                            },
                                            child: TaskCard(
                                              data: data,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      // left: MediaQuery.of(context).size.width * .40,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  //_addMarkers();
                                  showAddressMap();
                                },
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.map_outlined,
                                          color: Colors.white,
                                        ),
                                        CustomText(text: 'Map View')
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: searching,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.blueGrey.withOpacity(.9),
                        // color: Colors.pink,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredList.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (filteredList.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No data',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10.0, top: 10.0),
                                child: TaskCard(
                                  data: filteredList[index],
                                  backgroundColor: Colors.black45,
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

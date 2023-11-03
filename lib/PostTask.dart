import 'dart:convert';

import 'package:askit/CustomWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'DataModel.dart';

//maps imports
import 'dart:async';
import 'dart:io';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

const kGoogleApiKey = "AIzaSyDMeqRZlxa8ZRBtuz4FkS9S0iZ8H3T1Bb0";

class Post extends StatefulWidget {
  final String? category;
  final String? selectedIcon;
  const Post({Key? key, required this.category, this.selectedIcon}) : super(key: key);

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  late User? user;
  String _inputText = '';
  String? _selectedItem;
  late String username;
  bool isLoading = false;
  var uuid = const Uuid();
  String? _selectedCity;
  String? _jobType = 'in-person';
  bool _timeFlexible = false;
  bool _flexible = false;
  final List<String> _dropDownItems = ['one', 'two', 'three'];
  List<String> userTokens = [];
  List<XFile> selectedImages = [];
  List imagePaths = [];
  String? videoFile = '';
  late String vidUrl;
  String? _selectedTimeOfDay;
  final FlutterLocalNotificationsPlugin  notificationsPlugin = FlutterLocalNotificationsPlugin();
  late Future<QuerySnapshot> collectionSnapshot;
  final TextEditingController _taskTitle = TextEditingController();
  final TextEditingController _taskDescription = TextEditingController();
  final TextEditingController _taskRequirement = TextEditingController();
  final TextEditingController _completeAddress = TextEditingController();
  final TextEditingController _bugetController = TextEditingController();
  final TextEditingController _onDate = TextEditingController();
  final TextEditingController _beforeDate = TextEditingController();
  //maps
  GoogleMapsPlaces googlePlaces = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  final firestoreInstance = FirebaseFirestore.instance;  // handling all firestore collection
  final FirebaseAuth auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;  // for saving media in firebase storage
  final picker = ImagePicker();  // for picking image in phone gallery
  late LatLng _initialPosition;
  DateTime firstDate = DateTime.now();
  bool isFirstSelected = false;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  String? address;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  File? photo;
  bool signedAsProvider = false, showCompletedTasks = false;
  num rating = 0;
  int indIndex = 0;
  final List<String> categories = [
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
    'Socialising'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    getUsername();
  }

  getUsername() async{
    try{
      DocumentSnapshot snap = await firestoreInstance.collection('users').doc(auth.currentUser!.uid).get();
      if (snap.exists){
        Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
        setState(() {
          username = '${data['firstName']} ${data['lastName']}';
        });
      }
    }catch(e){
      return;
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
      showToastMessage('access denied', Colors.white);
    }
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
          // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
          //   return const Conversations(receiverId: '', profileName: '');
          // }));
        }else{}
      }catch(e){
        return;
      }
    });
  }
  void sendPushMessage(String token, String body, String title) async{
    try{
      await http.post(
          Uri.parse('https://fcm.googleapis.com/v1/projects/askit-5ff8c/messages:send HTTP/1.1'),
          headers: <String, String>{
            'Content-Type': "application/json",
            'Authorization': "Bearer 60693c26c90360664fbaade6b5ea2b003aa2c16f"
          },
          body: jsonEncode(
              <String, dynamic>{
                'priority': 'high',
                'data':<String, dynamic>{
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  'status': 'done',
                  'body': body,
                  'title':title,
                },
                "message":{
                  "tokens":userTokens,
                  "notification":{
                    'title':title,
                    'body':body,
                    "android_channel_id": "sentMessage"
                  }
                },
              }
          )
      );
    }catch(e){
      showToastMessage('$e', Colors.red);
    }
  }

  void grantLocationPermission() async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      if(context.mounted) ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content:Text('Location services are disabled')));
    }
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){

        if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Location permissions are denied')));
      }
    }
    if(permission == LocationPermission.deniedForever){

      if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Location permissions are permanently denied, we cannot request permissions')));
    }
  }

  Future<void> _showAutoComplete() async{
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        radius: 1000000,
        language: "en",
        onError: onError,
        mode: Mode.overlay,
        types: [],
        strictbounds: false,
        decoration: const InputDecoration(
            hintText: 'street, building, town...'
        ),
        components: [Component(Component.country, "in")]
    );
    displayPrediction(p!);
  }

  Future<void> displayPrediction(Prediction? prediction) async{
    if (prediction != null) {
      GoogleMapsPlaces googlePlaces = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail = await googlePlaces.getDetailsByPlaceId(prediction.placeId!);
      final lat = detail.result.geometry?.location.lat;  // latitude from the chosen address
      final lng = detail.result.geometry?.location.lng;  // longitude from the picked address
      var mapAddress = prediction.description!; // name of the address

      setState(() {
        _initialPosition = LatLng(lat!, lng!);
        address = mapAddress;
        _completeAddress.text = mapAddress;
        _markers.add(
            Marker(
                markerId: MarkerId(mapAddress),
                position: LatLng(lat, lng)
            )
        );
        _circles.add(
            Circle(
                circleId: CircleId(mapAddress),
                center: LatLng(lat, lng),
                radius: 500,
                fillColor: Colors.blue.withOpacity(0.4),
                strokeWidth: 2,
                strokeColor: Colors.blue
            )
        );
      });  // updated coordinates and address
    }
  }

  void onError(PlacesAutocompleteResponse response){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(response.errorMessage!)));
  }

  void showAddressMap(){
    if(address == null){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No address chosen')));
    } else{
      showGeneralDialog(
          context: context,
          pageBuilder: ((context, animation, secondaryAnimation) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: MaterialButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(CommunityMaterialIcons.chevron_left, color: Colors.white, size: 20),
                ),
                centerTitle: true,
                title: Text('$address', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),
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
                            target: _initialPosition,
                            zoom: 16,
                            tilt: 80,
                            bearing: 30
                        ),
                        onMapCreated: (GoogleMapController controller) => _controller.complete(controller),
                        markers: _markers,
                        circles: _circles,
                      )
                  )
                ],
              ),
            );
          })
      );
    }
  }

  Future<void> _pickVideo() async{
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickVideo(source: ImageSource.gallery);
    if(pickedFile != null){
      setState(() {
        videoFile = pickedFile.path;
      });
    }
  }

  Future<void> _pickImages() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickMultiImage();
    List<XFile> images = pickedFile;
    setState(() {
      if (images.isNotEmpty) {
        for (var i = 0; i < images.length; i++) {
          selectedImages.add(images[i]);
          // selectedImages.add(images[i].path);
        }
      } else {
        showToastMessage("No images selected", Colors.white);
      }
    });
  }
  Future<void> _storeImages(List<XFile> images) async{
    for(int i = 0; i<images.length; i++){
      final imagePath = File(images[i].path);
      final imageName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      try{
        TaskSnapshot uploadTask = await storage.ref().child('images/$imageName').putFile(imagePath);
        String imgUrl = await uploadTask.ref.getDownloadURL();
        imagePaths.add(imgUrl);
      }catch(error){
        showToastMessage('$error', Colors.red);
      }
    }
  }

  Future<void> _storeVideo() async{
    final String videoName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    try{
      TaskSnapshot uploadTask = await storage.ref().child('videos/$videoName').putFile(File(videoFile!));
      final String videoUrl = await uploadTask.ref.getDownloadURL();
      vidUrl = videoUrl;
    }catch(error){
      showToastMessage('Error uploading video', Colors.red);
    }
  }

  String? validateInput(String? value){
    if(value == null || value.isEmpty){
      return 'Field cannot be empty';
    }
    List<String>? words = value.split(' ');
    if(words.length > 10){
      return 'Maximum 10 characters allowed';
    }
    return null;
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
    SizedBox screen1(){
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Give a Title to your task',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            CustomText(text: 'Minimum 10 characters')
                          ],
                        ),
                      ),
                    ),
                    CustomTextField(
                        validator: validateInput,
                        width: MediaQuery.of(context).size.width * .95,
                        controller: _taskTitle,
                        hintText: 'What do yo need done?')
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: 'Describe your task briefly',
                              fontSize: 16,
                            ),
                            CustomText(text: 'Minimum 25 characters')
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: CustomTextField(
                          width: MediaQuery.of(context).size.width * .95,
                          maxLines: 4,
                          controller: _taskDescription,
                          hintText:
                          'Add more detailed description about the task and how you want it done'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: CustomTextField(
                          width: MediaQuery.of(context).size.width * .95,
                          controller: _taskRequirement,
                          hintText: 'Add specific requirements if any'),
                    ),
                    CustomTextField(
                        width: MediaQuery.of(context).size.width * .95,
                        controller: _bugetController,
                        hintText: 'Add your estimated budget amount'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    SizedBox screen2(){
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                width: MediaQuery.of(context).size.width * .80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _jobType = 'in-person';
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * .35,
                        height: 35,
                        decoration: BoxDecoration(
                            color: _jobType == 'in-person' ? Colors.grey : Colors.transparent,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: Text(
                            'In-Person',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _jobType == 'in-person' ? Colors.black : Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _jobType = 'remote';
                        });
                      },
                      child: Container(
                        height: 35,
                        width: MediaQuery.of(context).size.width * .35,
                        decoration: BoxDecoration(
                            color: _jobType == 'remote' ? Colors.grey : Colors.transparent,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: Text('Remotely',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _jobType == 'remote' ? Colors.black : Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: CustomText(
                        text: 'Change Task Category',
                        fontSize: 16,
                      ),
                    ),
                    CustomDropDown(
                      hint: '   Delivery',
                      items: categories,
                      onChanged: (value) {
                        setState(() {
                          _selectedItem = value;
                        });
                      },
                      iconImage: 'assets/taskIcons/Group.png',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: CustomText(
                        text: 'Add task images or videos',
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: ()=>_pickImages(),
                          child: Container(
                            color: Colors.white12,
                            height: 150,
                            width: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: selectedImages.isNotEmpty ? Image.asset(
                                      'assets/taskIcons/Group 2347.png'): Row(
                                    children: selectedImages.map((asset) => Container(
                                      width: 50,
                                      height: 50,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        // image: DecorationImage(
                                        //   fit: BoxFit.cover,
                                        //   image: AssetImage(asset as String,),
                                        // )
                                      ),
                                    )).toList(),
                                  )
                                ),
                                const Text(
                                  'Add up to 5 images of 1MB'
                                      ' each',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: ()=>_pickVideo(),
                          child: Container(
                            color: Colors.white12,
                            height: 150,
                            width: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    child: Image.asset('assets/taskIcons/Group 2350.png')),
                                const Text(
                                  'Add up to 1 video not more than'
                                      ' 10MB',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Visibility(
                visible: _jobType == 'in-person',
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10.0),
                        child: CustomText(
                          text: 'Enter task address',
                          fontSize: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: CustomDropDown(
                            hint: 'Select your city',
                            items: _dropDownItems,
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value;
                              });
                            }
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: (){
                            _showAutoComplete();
                          },
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * .95,
                            decoration: const BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(address != null ? _completeAddress.text : 'Add complete task address here',
                                ),
                              ),
                            ),
                          ),
                          // child: CustomTextField(
                          //     width: MediaQuery.of(context).size.width * .95,
                          //     maxLines: 3,
                          //     controller: _completeAddress,
                          //     hintText: 'Add complete task address here'),
                        )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: SizedBox(
                                    child: Image.asset(
                                        'assets/taskIcons/light.png'),
                                  ),
                                ),
                                const CustomText(
                                  text: 'Find address on map',
                                  fontSize: 14,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                // print(_initialPosition);
                                showAddressMap();
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    SizedBox screen3(){
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * .95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: CustomText(
                        text: 'When do you want it done?',
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomDatePicker(
                            hint: 'On Date', controller: _onDate, firstSelection: DateTime.now(), isFirstSelect: isFirstSelected,),
                        CustomDatePicker(
                            hint: 'Before Date', controller: _beforeDate, firstSelection: firstDate, isFirstSelect: isFirstSelected,)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .95,
                        decoration: const BoxDecoration(
                            color: Colors.white10,
                            borderRadius:
                            BorderRadius.all(Radius.circular(20))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: CustomText(
                                text: "Anytime, I'm flexible",
                                fontSize: 16,
                              ),
                            ),
                            Switch(
                              value: _timeFlexible,
                              onChanged: (value) {
                                setState(() {
                                  _timeFlexible = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * .95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: CustomText(
                      text: 'Select your preferred time',
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            _selectedTimeOfDay = 'morning';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10),
                            ),
                            border: _selectedTimeOfDay == 'morning' ? Border.all(
                              color: Colors.white,
                            ) : null,
                          ),
                          height: 100,
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Image.asset(
                                    'assets/taskIcons/Group 2449.png'),
                              ),
                              const CustomText(text: 'Before 11 am')
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            _selectedTimeOfDay = 'midday';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10),
                            ),
                            border: _selectedTimeOfDay == 'midday' ? Border.all(
                              color: Colors.white,
                            ) : null,
                          ),
                          height: 100,
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Image.asset(
                                    'assets/taskIcons/Vector.png'),
                              ),
                              const CustomText(text: '11 am - 4 pm')
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            _selectedTimeOfDay = 'evening';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(10),
                            ),
                            border: _selectedTimeOfDay == 'evening' ? Border.all(
                              color: Colors.white,
                            ) : null,
                          ),
                          height: 100,
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Image.asset(
                                    'assets/taskIcons/Group (1).png'),
                              ),
                              const CustomText(text: 'After 4 pm')
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * .95,
                      decoration: const BoxDecoration(
                          color: Colors.white10,
                          borderRadius:
                          BorderRadius.all(Radius.circular(20))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: CustomText(
                              text: "Anytime, I'm flexible",
                              fontSize: 16,
                            ),
                          ),
                          Switch(
                            value: _flexible,
                            onChanged: (value) {
                              setState(() {
                                _flexible = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Expanded(
              child: SizedBox(
                height: 10,
              ),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                if(selectedImages.isNotEmpty){
                  await _storeImages(selectedImages);
                }
                if(videoFile != ''){
                 await _storeVideo();
                }
                var taskUuid = uuid.v1();
                TaskModel taskModel = TaskModel(
                    user_id: user?.uid ?? '',
                    title: _taskTitle.text,
                    status: 'open',
                    Task_id: taskUuid,
                    description: _taskDescription.text,
                    requirements: _taskRequirement.text,
                    category: widget.category!,
                    media_url: imagePaths,
                    offers: [],
                    vidPath: vidUrl,
                    city: _selectedCity!,
                    address: _completeAddress.text,
                    on_date: _onDate.text,
                    before_date: _beforeDate.text,
                    flexible_time: _flexible,
                    preferred_time: _selectedTimeOfDay!,
                    flexible_date: _timeFlexible,
                    country: '',
                    lng_coordinate: '',
                    lat_coordinate: '',
                    provider_id: '',
                    on_date_formatted: DateTime.now(),
                    png_icon: widget.selectedIcon!,
                    task_type: _jobType!,
                    complete: false,
                    star_rate: 3,
                    username: username);
                Map<String, dynamic> dataMap = taskModel.toMap();
                await FirebaseFirestore.instance
                    .collection("Tasks").doc(taskUuid).set(dataMap);
                AlertModel alertModel = AlertModel(alertType: 'task', taskTitle: _taskTitle.text, address: '',
                    taskBudget: '', timeStamp: DateTime.now(), taskId: taskUuid, msgSender: '',
                    msgBody: '', msgReceiver: '', taskDescription: _taskDescription.text, taskDueDate: _onDate.text,
                    uploadId: auth.currentUser!.uid, taskUrl: widget.selectedIcon!, username: '');
                Map<String, dynamic> alertData = alertModel.toMap();
                await FirebaseFirestore.instance.collection('Alerts').add(alertData);
                _completeAddress.clear();
                _taskDescription.clear();
                _taskTitle.clear();
                _beforeDate.clear();
                _onDate.clear();
                _taskRequirement.clear();
                setState(() {
                  isLoading = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * .65,
                  height: 50,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: isLoading ? const CircularProgressIndicator(): const Text(
                      'Continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final List<Widget> pages = [
      screen1(),
      screen2(),
      screen3()
    ];
    int currentPage = 0;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .33,
                child: Divider(
                  thickness: 2.0,
                  color: indIndex == 0 ? Colors.white : Colors.white30,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .34,
                child: Divider(
                  thickness: 2.0,
                  color: indIndex == 1 ? Colors.white : Colors.white30,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .33,
                child: Divider(
                  thickness: 2.0,
                  color: indIndex == 2 ? Colors.white : Colors.white30,
                ),
              ),
            ],
          ),
          Expanded(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                onHorizontalDragEnd: (details){
                  if(details.primaryVelocity! > 0){
                    if(currentPage > 0){
                      setState(() {
                        currentPage --;
                      });
                    }
                  }else if(details.primaryVelocity! < 0){
                    if(currentPage < pages.length-1){
                      setState(() {
                        currentPage ++;
                      });
                    }
                  }
                },
                child: PageView(
                  children: pages,
                  onPageChanged: (index){
                    setState(() {
                      currentPage = index;
                      indIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
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
        'Post a task',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}

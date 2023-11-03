import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

const kGoogleApiKey = "AIzaSyDMeqRZlxa8ZRBtuz4FkS9S0iZ8H3T1Bb0";

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Askit online project',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a blue toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//           colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff163BF4)),
//           useMaterial3: true,
//           fontFamily: 'montserrat'
//       ),
//       home: const MyHomePage(title: 'Askit Home Page'),
//     );
//   }
// }

class Profile extends StatefulWidget {
  const Profile({super.key, required this.title});

  final String title;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  GoogleMapsPlaces googlePlaces = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  final firestoreInstance = FirebaseFirestore.instance;  // handling all firestore collection
  final storage = FirebaseStorage.instance;  // for saving media in firebase storage
  final picker = ImagePicker();  // for picking image in phone gallery
  late LatLng _initialPosition;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  String? address;
  final Completer<GoogleMapController> _controller = Completer();
  File? photo;
  bool signedAsProvider = false, showCompletedTasks = false;
  num rating = 0;

  @override
  void initState(){
    super.initState();
    checkGalleryPermission();
    userLoggedDetails();
    _showCompletedTasks();
  }

  void checkGalleryPermission() async{
    var status = await Permission.storage.status;
    if(status.isDenied){
      await Permission.storage.request();
    }
    await Permission.storage.request();
  }  // for asking access to phone gallery

  void addProfilePicture() async{
    final pickedPhoto = await picker.pickImage(source: ImageSource.gallery);
    setState((){
      if(pickedPhoto != null){
        photo = File(pickedPhoto.path);
      }
    });
  }  // opening phone gallery and pick image of choice

  void userLoggedDetails() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? uid = pref.getString('uid');
    if(uid != null){
      firestoreInstance.collection('users').where('user_id', isEqualTo: uid).get().then((value){
        if(value.docs.isNotEmpty){
          for (var element in value.docs) {
            rating = element.data()['rating_sum']/element.data()['no_of_people_rated'];
            if(element.data()['signed_as'] == 'provider'){
              setState(() {
                signedAsProvider = true;
              });
            }
          }
        }
      });
    }
  }  // for getting the star rating and if user signed as provider or requester

  void _showCompletedTasks() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? uid = pref.getString('uid');
    firestoreInstance.collection('tasks').where('provider_id', isEqualTo: uid).get().then((value){
      if(value.docs.isNotEmpty){
        setState(() {
          showCompletedTasks = true;
        });
      }
    });
  } // if complete tasks are available notEmpty

  Stream<QuerySnapshot> completedTaskDetails() async*{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var uid = pref.getString('uid');
    var qs = firestoreInstance.collection('tasks').where('provider_id', isEqualTo: uid).where('complete', isEqualTo: true).snapshots();
    yield* qs;
  }  // for finding all completed tasks by provider in firestore

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
      var address = prediction.description!; // name of the address

      setState(() {
        _initialPosition = LatLng(lat!, lng!);
        address = address;
        _markers.add(
            Marker(
                markerId: MarkerId(address),
                position: LatLng(lat, lng)
            )
        );
        _circles.add(
            Circle(
                circleId: CircleId(address),
                center: LatLng(lat, lng),
                radius: 1000,
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
                backgroundColor: Colors.white,
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
                            zoom: 13,
                            tilt: 80,
                            bearing: 30
                        ),
                        onMapCreated: (controller) => _controller.complete(controller),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF080808),
        appBar: AppBar(
          backgroundColor: const Color(0xFF080808),
          leading: MaterialButton(
              child: const Icon(CommunityMaterialIcons.chevron_left, color: Colors.white, size: 30.0,),
              onPressed: () => Navigator.pop(context)
          ),
          actions: [
            Container(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset('assets/askitIcons/profileEdit/Edit.svg', width: 16, height: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 6),
                    child: const Text('Edit Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),),
                  )
                ],
              ),
            )
          ],
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 52),
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              color: Color(0xFF2F2F2F)
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                            children: [
                              Positioned.fill(
                                  child: CircleAvatar(
                                    radius: 80.0,
                                    child: Image.asset('assets/profileIcons/Group 2389.png'),
                                  )
                              ),
                              Positioned(
                                  top: 6,
                                  left: 0,
                                  child: GestureDetector(
                                    onTap: addProfilePicture,
                                    child: Image.asset('assets/profileIcons/Group 2413.png', width: 25, height: 25),
                                  )
                              ),
                              Positioned(
                                bottom: 4,
                                right: 6,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 3, color: Colors.white),
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.green,
                                  ),
                                ),
                              )
                            ]
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text('Aarushi Singh', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18), textAlign: TextAlign.start,),
                                  SvgPicture.asset('assets/profileIcons/Vector.png', width: 18, height: 18,)
                                ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset('assets/askitIcons/profileEdit/Location_Icon.svg', width: 18, height: 18,),
                                const Text('Thane, Mumbai', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xff909497)))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(width: 1, color: Colors.grey), bottom: BorderSide(width: 1, color: Colors.grey))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width/2,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: Column(
                            children: [
                              const Text('As Service Provider', style: TextStyle(color: Colors.white),),
                              Container(
                                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                                  child: const Text('4.0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                              Image.asset('assets/profileIcons/Group 2417.png', height: 20)
                            ],
                          )),
                      Container(
                          width: MediaQuery.of(context).size.width/2,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          decoration: const BoxDecoration(
                              border: Border(left: BorderSide(width: 1, color: Colors.grey))
                          ),
                          child: Column(
                            children: [
                              const Text('As Service Requester', style: TextStyle(color: Colors.white),),
                              Container(
                                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                                  child: const Text('N/A', style: TextStyle(fontSize: 14, color: Colors.white))),
                              Image.asset('assets/profileIcons/Group 2416.png', height: 20)
                            ],
                          )
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: const Text('Work History - (Completed Tasks)', style: TextStyle(fontSize: 18, color: Colors.white),),
                ),
                Container(
                    child: showCompletedTasks == true? StreamBuilder<QuerySnapshot>(
                        stream: completedTaskDetails(),
                        builder: (context, snapshot) {
                          if(snapshot.hasError || !snapshot.hasData){
                            return Container(
                                alignment: Alignment.center,
                                child: const Text('Something went wrong!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),)
                            );
                          }
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data?.docs.length,
                              itemBuilder: (context, index){
                                DocumentSnapshot item = snapshot.data!.docs[index];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(item['provider_id']),
                                );
                              }
                          );
                        }
                    )
                        : Container(
                        margin: const EdgeInsets.only(top: 32),
                        child: const Text('All finished tasks will be shown here.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),)
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}